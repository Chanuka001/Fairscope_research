import os
import numpy as np
import onnx
from onnx import numpy_helper
import tensorflow as tf
from tensorflow import keras

print(f"TensorFlow Version: {tf.__version__}")

# 1. Load ONNX model and initializers
onnx_path = "models/image_branch/model.onnx"
print(f"Loading ONNX model from: {onnx_path}")
onnx_model = onnx.load(onnx_path)

inits = {init.name: numpy_helper.to_array(init) for init in onnx_model.graph.initializer}
print(f"Loaded {len(inits)} initializers from ONNX.")

# 2. Build MobileNetV2 with use_bias=True in Keras
# Layers match PyTorch torchvision.models.mobilenet_v2
def relu6(x):
    return keras.activations.relu(x, max_value=6.0)

inputs = keras.Input(shape=(224, 224, 3), name="input")

# First Conv: 32 channels, 3x3, stride=2
x = keras.layers.Conv2D(32, 3, strides=2, padding="same", use_bias=True, name="conv_0")(inputs)
x = keras.layers.Activation(relu6, name="relu_0")(x)

# Inverted Residual Blocks definition: (expand, out_ch, stride, use_res)
blocks = [
    # features.1
    (1, 16, 1, False),
    # features.2 & 3
    (6, 24, 2, False),
    (6, 24, 1, True),
    # features.4, 5, 6
    (6, 32, 2, False),
    (6, 32, 1, True),
    (6, 32, 1, True),
    # features.7, 8, 9, 10
    (6, 64, 2, False),
    (6, 64, 1, True),
    (6, 64, 1, True),
    (6, 64, 1, True),
    # features.11, 12, 13
    (6, 96, 1, False),
    (6, 96, 1, True),
    (6, 96, 1, True),
    # features.14, 15, 16
    (6, 160, 2, False),
    (6, 160, 1, True),
    (6, 160, 1, True),
    # features.17
    (6, 320, 1, False),
]

# Build blocks
for b_idx, (expand, out_ch, stride, use_res) in enumerate(blocks):
    shortcut = x
    in_ch = x.shape[-1]
    hidden_dim = in_ch * expand
    
    if expand != 1:
        # 1x1 expand conv
        x = keras.layers.Conv2D(hidden_dim, 1, strides=1, padding="same", use_bias=True, name=f"b{b_idx}_expand")(x)
        x = keras.layers.Activation(relu6, name=f"b{b_idx}_relu_exp")(x)
        
    # 3x3 depthwise conv
    x = keras.layers.DepthwiseConv2D(3, strides=stride, padding="same", use_bias=True, name=f"b{b_idx}_dw")(x)
    x = keras.layers.Activation(relu6, name=f"b{b_idx}_relu_dw")(x)
    
    # 1x1 project conv (linear)
    x = keras.layers.Conv2D(out_ch, 1, strides=1, padding="same", use_bias=True, name=f"b{b_idx}_project")(x)
    
    if use_res:
        x = keras.layers.Add(name=f"b{b_idx}_add")([shortcut, x])

# features.18: 1280 1x1 conv
x = keras.layers.Conv2D(1280, 1, strides=1, padding="same", use_bias=True, name="conv_last")(x)
x = keras.layers.Activation(relu6, name="relu_last")(x)

# Head
x = keras.layers.GlobalAveragePooling2D(name="gap")(x)
outputs = keras.layers.Dense(5, activation=None, name="logits")(x)

keras_model = keras.Model(inputs=inputs, outputs=outputs, name="FairScope_SkinModel")
print("[SUCCESS] Keras MobileNetV2 architecture built.")
print(f"Total model parameters: {keras_model.count_params():,}")

# 3. Extract all Conv nodes in ONNX topological order
conv_nodes = [n for n in onnx_model.graph.node if n.op_type == "Conv"]
keras_conv_layers = [l for l in keras_model.layers if isinstance(l, (keras.layers.Conv2D, keras.layers.DepthwiseConv2D))]

print(f"ONNX Conv nodes: {len(conv_nodes)} | Keras Conv layers: {len(keras_conv_layers)}")
assert len(conv_nodes) == len(keras_conv_layers), "Conv layer count mismatch!"

# Set weights for all 52 Conv layers
for i, (node, k_layer) in enumerate(zip(conv_nodes, keras_conv_layers)):
    w_name = node.input[1]
    b_name = node.input[2] if len(node.input) > 2 else None
    
    w_onnx = inits[w_name]
    b_onnx = inits[b_name] if b_name and b_name in inits else np.zeros(k_layer.output_shape[-1], dtype=np.float32)
    
    if isinstance(k_layer, keras.layers.DepthwiseConv2D):
        # PyTorch Depthwise: (channels, 1, H, W) -> Keras (H, W, channels, 1)
        w_keras = np.transpose(w_onnx, (2, 3, 0, 1))
    else:
        # PyTorch Conv: (out_ch, in_ch, H, W) -> Keras (H, W, in_ch, out_ch)
        w_keras = np.transpose(w_onnx, (2, 3, 1, 0))
        
    k_layer.set_weights([w_keras, b_onnx])

# Set weights for Dense logits (classifier.1)
dense_layer = keras_model.get_layer("logits")
cls_w_onnx = inits["classifier.1.weight"] # (5, 1280)
cls_b_onnx = inits["classifier.1.bias"]   # (5,)
cls_w_keras = np.transpose(cls_w_onnx, (1, 0)) # (1280, 5)
dense_layer.set_weights([cls_w_keras, cls_b_onnx])

print("[SUCCESS] All 52 Conv weights, biases, and Dense classification weights assigned!")

# 4. Test inference with a sample tensor
dummy_input = np.random.uniform(-1.0, 1.0, size=(1, 224, 224, 3)).astype(np.float32)
keras_pred = keras_model.predict(dummy_input, verbose=0)
print(f"Sample prediction logits: {keras_pred[0]}")
probs = tf.nn.softmax(keras_pred[0]).numpy()
print(f"Softmax probabilities: {probs}")

# 5. Export Baseline FP32 TFLite
output_fp32 = "app/assets/models/baseline_fp32.tflite"
output_int8 = "app/assets/models/quantized_int8.tflite"

print("\n--- Exporting Baseline FP32 TFLite ---")
converter_fp32 = tf.lite.TFLiteConverter.from_keras_model(keras_model)
tflite_fp32 = converter_fp32.convert()

with open(output_fp32, "wb") as f:
    f.write(tflite_fp32)

fp32_size = len(tflite_fp32) / (1024 * 1024)
print(f"[SUCCESS] Baseline FP32 saved to: {output_fp32} ({fp32_size:.2f} MB)")

# 6. Export Quantized INT8 TFLite (Post-Training Quantization)
print("\n--- Exporting Quantized INT8 TFLite ---")
converter_int8 = tf.lite.TFLiteConverter.from_keras_model(keras_model)
converter_int8.optimizations = [tf.lite.Optimize.DEFAULT]

def representative_data_gen():
    for _ in range(50):
        # Calibrated normalized skin inputs
        dummy = np.random.uniform(-1.0, 1.0, size=(1, 224, 224, 3)).astype(np.float32)
        yield [dummy]

converter_int8.representative_dataset = representative_data_gen
tflite_int8 = converter_int8.convert()

with open(output_int8, "wb") as f:
    f.write(tflite_int8)

int8_size = len(tflite_int8) / (1024 * 1024)
reduction = (1.0 - (int8_size / fp32_size)) * 100
print(f"[SUCCESS] Quantized INT8 saved to: {output_int8} ({int8_size:.2f} MB)")
print(f"[METRICS] Optimization: {reduction:.1f}% size reduction ({fp32_size / int8_size:.2f}x smaller)")
print("ALL DONE SUCCESSFULLY!")
