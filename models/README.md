# Models

This directory contains the machine learning pipelines for model training, fusion, compression, and explainability experiments.

## Subdirectories

- **`image_branch/`** `[Member A]`
  - Convolutional/Vision Transformer models trained on facial dermatological images.
  - Handles rare-class imbalance using focal loss, cost-sensitive learning, and class re-weighting.
- **`sensor_branch/`** `[Member B]`
  - Neural networks processing tabular/time-series readings from the hardware sensor probe (moisture, spectral/color).
- **`fusion/`** `[Members A + B]`
  - Intermediate/late fusion architectures combining image embeddings and physical sensor features.
- **`compressed/`** `[Member C]`
  - Quantization-Aware Training (QAT), Post-Training Quantization (PTQ - INT8/FP16), structured pruning, and TensorFlow Lite (`.tflite`) export pipelines.
- **`explainability/`** `[Member D]`
  - Saliency mapping (Grad-CAM) for image inputs and feature attribution (SHAP/Integrated Gradients) across fused image and sensor features.
  - Cross-dataset fairness evaluations grouped by Fitzpatrick skin tone types (I-VI).

## Environment Setup

```bash
python -m venv .venv
# Linux/macOS:
source .venv/bin/activate
# Windows:
.venv\Scripts\activate

pip install -r requirements.txt
```
