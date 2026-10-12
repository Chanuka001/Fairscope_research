# FairScope

> A Deployment-Readiness Phone App for Multimodal AI-Based Facial Skin Condition Analysis (with IoT Sensor Probe)

## 📖 Overview

AI-based facial skin analysis systems report high accuracy in controlled research settings, yet few reach real-world deployment due to diagnostic bias against darker skin tones, heavy computational requirements, lack of explainability, and the absence of physical surface signals (e.g., hydration).

**FairScope** bridges these gaps by delivering a working, multimodal system as a single phone app. It pairs the user's phone (handling camera, compute, and display) with a low-cost wireless IoT sensor probe that reads physical skin properties. This system makes rare-class detection, compression trade-offs, explainability, and cross-population fairness directly visible and testable side by side.

## 🎯 Objectives

To design and build a working multimodal AI-and-IoT facial skin condition analysis system demonstrating real-world deployment readiness across:

* Rare-condition detection accuracy
* Real-time performance under compression on phone hardware
* Prediction explainability
* Fairness across diverse skin tones

## 🏗️ Hardware & System Architecture

* **IoT Sensor Probe:** A low-cost microcontroller (e.g., ESP32) with a moisture/hydration sensor and a spectral/color sensor. It captures physical readings and transmits them wirelessly via BLE or Wi-Fi.
* **Phone Application:** Captures facial images via the camera, receives sensor readings from the probe, runs the compressed fusion model locally, and displays both the everyday scan result and the in-app research panels on its own screen.

## 👥 Team Responsibilities (Updated)

### Member A (AI: Image Branch & Rare-Class Detection)

* **Focus:** Evaluate detection accuracy on rare/severe skin conditions vs. dominant benign cases.
* **Tasks:** Train/fine-tune the base image classifier on public datasets (Fitzpatrick17k, ACNE04, DDI, HAM10000). Address class imbalance (e.g., focal loss, resampling). Build the app's camera capture and scan-result screens, and the in-app panel showing per-class accuracy. Co-design and train the fusion layer (image-branch integration).

### Member B (IoT: Sensor Probe Hardware)

* **Focus:** Build the wireless IoT sensor probe and train the sensor-input model.
* **Tasks:** Design and assemble the sensor probe (microcontroller, moisture/spectral sensor, BLE/Wi-Fi transmitter). Train/calibrate the sensor-input model on paired sensor readings, handling rare-case detection on the sensor branch. Build the app's BLE/Wi-Fi pairing and sensor capture screens. Stream probe data to the phone and build the sensor/fusion status panel. Co-design and train the fusion layer (sensor-branch integration).

### Member C (Deploy: Compression & On-Phone Optimization)

* **Focus:** Optimize the fusion model for real-time deployment on the user's phone.
* **Tasks:** Apply quantization and pruning to the fusion model and export it to a mobile runtime (e.g., TensorFlow Lite or PyTorch Mobile). Benchmark real-world latency and throughput directly on phone hardware. Own the app's core navigation/state shell and integrate the compressed model's inference call. Build the in-app panel showing the live original-vs-compressed inference comparison.

### Member D (AI: Explainability & Fairness)

* **Focus:** Evaluate explainability and fairness of the fused predictions across image and sensor modalities.
* **Tasks:** Apply SHAP/Grad-CAM to the image branch and feature-attribution to the sensor branch to design human-readable fused explanations. Run cross-dataset generalization testing and measure performance drift by Fitzpatrick skin type and class rarity. Build the app's consent/onboarding flow and the in-app panel with explainability overlays and the fairness-gap chart. (Note: Uses Grad-CAM for live on-device explanations).

## 🔬 Evaluation & Deliverables

The primary deliverable is the **FairScope App**, a single phone application paired with the IoT sensor probe. During a live panel evaluation, the system will demonstrate:

1. Touching the probe to the skin and taking a phone photo.
2. Real-time fused image+sensor classification with confidence and Grad-CAM explanations.
3. Live comparisons of the compressed vs. full model running on the phone hardware.
4. An analysis of the fairness gap across skin tones with and without sensor fusion.

*Stretch Goal: A standalone browser dashboard mirroring the app's research views for larger-screen presentations.*
