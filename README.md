# FairScope

**A Deployment-Readiness System for Multimodal AI-Based Facial Skin Condition Analysis, with an IoT Sensor Probe**

Final-year research project, SLIIT | Project ID: J26-IT-371

---

## 1. Overview

AI-based facial skin analysis systems report high accuracy in controlled research settings, yet few reach real-world use. The common blockers are:

- **Bias:** worse diagnosis on darker skin tones
- **Heavy compute:** models too large or slow for everyday devices
- **No explainability:** predictions users and clinicians cannot inspect
- **Missing physical signals:** images alone cannot capture properties like hydration

**FairScope** addresses these together. It combines an image from a low-cost wireless probe (ESP32-CAM) and the probe's skin sensor readings, fuses them in one model, compresses that model to run on a phone, and makes the trade-offs (rare-class accuracy, compression cost, explainability, fairness) visible and testable.

## 2. Objectives

Build and demonstrate a working multimodal AI-and-IoT system that shows deployment readiness across:

1. **Rare-condition detection accuracy**, not only common benign cases
2. **Real-time performance under compression** on phone hardware
3. **Prediction explainability** for fused image and sensor predictions
4. **Fairness across skin tones** (Fitzpatrick types), with and without sensor fusion

## 3. System at a glance

```
 ┌──────────────────────────────┐
 │  Wireless probe (firmware/)  │  ESP32-CAM + OV2640 camera
 │                              │  + moisture + spectral/color sensor
 └─────────────┬────────────────┘
               │ Wi-Fi: JPEG image + sensor readings
               ▼
 ┌──────────────────────────────────────────────┐
 │  Phone app (app/)                            │
 │  receives image and sensor readings          │
 │  → preprocessing                             │
 │  → compressed fusion model (on-device)       │
 │  → scan result, confidence, Grad-CAM         │
 │  → research panels (compression comparison,  │
 │     explainability, fairness)                │
 └─────────────┬────────────────────────────────┘
               │ exported results (JSON)
               ▼
 ┌──────────────────────┐
 │  Dashboard           │  browser view for larger screens
 │  (dashboard/)        │
 └──────────────────────┘

 Offline: models/ (training, fusion, compression, explainability)
          produce the model files and the result files above.
```

The camera is on the probe, not on the phone. The phone does not use its own camera. The model runs on the phone, not on the probe.

**App flow** (two tabs: Analyse and History):

```
Connect probe → capture cards (delete / analyse) → result summary → explanation (Grad-CAM) → performance dashboard
```

Only analysed captures are saved to History. The performance dashboard is a research view and is not part of the real-world use of the app. Details are in `app/README.md`.

## 4. Components and team

| Member | Area | Responsibilities | Main folders |
|---|---|---|---|
| **A** | AI: image branch and rare-class detection | Train and fine-tune the image classifier (tested on OV2640 probe images), handle class imbalance (focal loss, resampling), per-class accuracy, co-design the fusion layer | `models/image_branch/`, result widgets in `app/lib/features/analyse/result/` |
| **B** | IoT: wireless probe | Build the probe (ESP32-CAM with OV2640 camera, moisture and color sensors, Wi-Fi), serve images and sensor readings to the phone, train the sensor model, co-design the fusion layer | `firmware/`, `models/sensor_branch/`, probe widgets in `app/lib/features/analyse/connect/` |
| **C** | Deployment: compression and on-phone optimization | Quantization and pruning, export to a mobile runtime (TensorFlow Lite), benchmark latency and throughput on a real phone, own the app shell, the probe service interface, image preprocessing and the model inference call | `models/compressed/`, `benchmarks/`, `app/lib/core/`, `app/lib/features/analyse/performance/`, `app/lib/features/history/` |
| **D** | AI: explainability and fairness | Grad-CAM and SHAP / feature attribution, cross-dataset generalization, performance by Fitzpatrick type and class rarity, consent and onboarding flow | `models/explainability/`, `results/`, `app/lib/features/analyse/explain/`, `app/lib/features/onboarding/` |

The fusion model (`models/fusion/`) is co-owned by A and B, then handed to C for compression.

## 5. Repository structure

```
fairscope/
├── README.md                  # This file (project root guide)
├── .gitignore
│
├── models/                    # Model training and processing (Python)
│   ├── image_branch/          # [A] Image classifier
│   ├── sensor_branch/         # [B] Sensor-input model
│   ├── fusion/                # [A+B] Fusion layer
│   ├── compressed/            # [C] Quantization, pruning, TFLite export
│   ├── explainability/        # [D] Grad-CAM / SHAP experiments
│   └── README.md
│
├── firmware/                  # [B] ESP32 probe code
│   ├── src/
│   └── README.md              # Wiring, flashing, data protocol
│
├── app/                       # Flutter phone app (main deliverable)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/              # [C] Navigation, state, model interface, theme
│   │   ├── features/
│   │   │   ├── analyse/       # 4-step flow
│   │   │   │   ├── connect/   # [B + C] Probe status, capture cards
│   │   │   │   ├── result/    # [A + C] Result summary
│   │   │   │   ├── explain/   # [D] Grad-CAM explanation
│   │   │   │   └── performance/ # [C] Performance dashboard (fp32 vs int8, accuracy, fairness)
│   │   │   ├── history/       # [C] Analysed scans only
│   │   │   └── onboarding/    # [D] Consent and onboarding
│   │   └── shared/            # Reusable widgets and utilities
│   ├── assets/models/         # .tflite files bundled in the app
│   ├── test/
│   └── pubspec.yaml
│
├── dashboard/                 # Optional read-only browser dashboard (Next.js)
│   └── README.md
│
├── benchmarks/                # [C] Latency, size, RAM, accuracy results (JSON)
├── results/                   # [A, D] Per-class and fairness results (JSON)
│
├── data/                      # NOT committed: dataset notes and download scripts
│   └── README.md
│
└── docs/
    ├── taf/                   # TAF document
    ├── proposals/             # Individual proposals
    ├── diagrams/              # System and component diagrams
    └── presentations/         # Progress and final presentation slides
```

Each major folder has its own `README.md` with details for that part. Keep this root file as the overview.

## 6. Data and datasets

Public, de-identified datasets only:

- Fitzpatrick17k
- ACNE04
- DDI (Diverse Dermatology Images)
- HAM10000

Datasets are **not** stored in this repository. See `data/README.md` for sources and download steps. Sensor readings are collected with the probe under the consent process described in the app's onboarding flow.

## 7. Shared data contract

Models, the app and the dashboard communicate through JSON result files in `benchmarks/` and `results/`. Agree on formats early and update this section when they change.

Example: `benchmarks/latency/<date>_<device>.json`

```json
{
  "device": "Device name",
  "date": "YYYY-MM-DD",
  "model_version": "fusion_v1",
  "variants": [
    {
      "name": "original_float32",
      "size_mb": 0.0,
      "latency_ms_mean": 0.0,
      "peak_ram_mb": 0.0,
      "accuracy_overall": 0.0,
      "accuracy_rare": 0.0
    },
    {
      "name": "quantized_int8",
      "size_mb": 0.0,
      "latency_ms_mean": 0.0,
      "peak_ram_mb": 0.0,
      "accuracy_overall": 0.0,
      "accuracy_rare": 0.0
    }
  ]
}
```

Fairness results use Fitzpatrick type keys (I to VI) with and without sensor fusion.

## 8. Tech stack

| Part | Technology |
|---|---|
| Model training | Python, TensorFlow / Keras |
| Compression and export | TensorFlow Lite (quantization, pruning) |
| Explainability | Grad-CAM, SHAP |
| Wireless probe | ESP32-CAM (OV2640 camera), moisture and color sensors, Wi-Fi |
| Phone app | Flutter, `tflite_flutter`, HTTP client (talks to the probe over Wi-Fi) |
| Dashboard (optional) | Next.js |
| Collaboration | Git and GitHub |

## 9. Getting started

### Models (Python)
```bash
cd models
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Firmware (ESP32)
See `firmware/README.md` for wiring, board setup and flashing.

### Phone app
```bash
cd app
flutter pub get
flutter run                      # Android phone connected with USB debugging
```

### Dashboard (optional)
```bash
cd dashboard
npm install
npm run dev
```

## 10. Evaluation and deliverables

**Primary deliverable:** the FairScope system, a phone app paired with the wireless probe (ESP32-CAM and skin sensors).

In a live panel evaluation, the system demonstrates:

1. Touching the probe to the skin and capturing an image with the probe camera, which sends it to the phone
2. Real-time fused image and sensor classification with confidence and Grad-CAM explanation
3. A performance dashboard with a live comparison of the compressed vs full model running on the phone
4. Fairness-gap analysis across skin tones, with and without sensor fusion

**Extra deliverable:** a browser dashboard that mirrors the app's research views for larger screens.

## 11. Git workflow

1. `main` always works and is demo-ready. Nobody pushes to it directly.
2. Create a branch per task: `type/area-short-description` (for example `feat/compression-quantization`, `feat/sensor-ble-pairing`, `fix/comparison-panel-crash`).
3. Commit small and often with clear messages.
4. Open a pull request into `main`; at least one other member reviews it.
5. Pull from `main` before starting new work.
6. Edit files in your own folders. For changes in someone else's area, ask them or open a PR for their review.

**Large files:** do not commit datasets. Use Git LFS or GitHub Releases for large model files. Never commit passwords, API keys, or personal images.

## 12. Ethics

- Only public, de-identified datasets are used for training and evaluation.
- Images captured during testing require participant consent and are never committed.
- Fairness results are reported honestly, including gaps between skin types.
- FairScope is a research prototype, not a medical diagnostic device.

## 13. Project status

| Area | Owner | Status |
|---|---|---|
| Image branch and rare-class detection | A | Not started |
| Wireless probe hardware (ESP32-CAM and sensors) | B | Not started |
| Sensor model | B | Not started |
| Fusion model | A + B | Not started |
| Compression and TFLite export | C | Not started |
| On-phone benchmarks | C | Not started |
| App shell and navigation | C | Not started |
| Explainability and fairness | D | Not started |
| Dashboard | Team | Not started |

Update this table as work progresses.

## 14. Team

| Member | Name | GitHub |
|---|---|---|
| A | | |
| B | | |
| C | | |
| D | | |

Supervisor: