# FairScope

> A Deployment-Readiness System for Multimodal AI-Based Facial Skin Condition Analysis, with an IoT Sensor Probe

Final-year research project, SLIIT | Project ID: J26-IT-371

---

## 1. Overview

AI-based facial skin analysis systems report high accuracy in controlled research settings, yet few reach real-world use. The common blockers are:

- **Bias:** worse diagnosis on darker skin tones
- **Heavy compute:** models too large or slow for everyday devices
- **No explainability:** predictions users and clinicians cannot inspect
- **Missing physical signals:** images alone cannot capture properties like hydration

**FairScope** addresses these together. It combines a camera image and readings from a low-cost wireless sensor probe, fuses them in one model, compresses that model to run on a phone, and makes the trade-offs (rare-class accuracy, compression cost, explainability, fairness) visible and testable.

## 2. Objectives

Build and demonstrate a working multimodal AI-and-IoT system that shows deployment readiness across:

1. **Rare-condition detection accuracy**, not only common benign cases
2. **Real-time performance under compression** on phone hardware
3. **Prediction explainability** for fused image and sensor predictions
4. **Fairness across skin tones** (Fitzpatrick types), with and without sensor fusion

## 3. System at a glance

```text
 ┌──────────────────────┐
 │  IoT sensor probe    │  ESP32 + moisture + spectral/color sensor
 │  (firmware/)         │
 └─────────┬────────────┘
           │ BLE / Wi-Fi
           ▼
 ┌──────────────────────────────────────────────┐
 │  Phone app (app/)                            │
 │  camera + sensor input                       │
 │  → compressed fusion model (on-device)       │
 │  → scan result, confidence, Grad-CAM         │
 │  → research panels (accuracy, compression,   │
 │     fairness)                                │
 └─────────┬────────────────────────────────────┘
           │ exported results (JSON)
           ▼
 ┌──────────────────────┐
 │  Dashboard           │  browser view for larger screens
 │  (dashboard/)        │
 └──────────────────────┘

 Offline: models/ (training, fusion, compression, explainability)
          produce the model files and the result files above.
```

## 4. Components and team

| Member | Area | Responsibilities | Main folders |
| --- | --- | --- | --- |
| **A** | AI: image branch and rare-class detection | Train and fine-tune the image classifier, handle class imbalance (focal loss, resampling), per-class accuracy, co-design the fusion layer | `models/image_branch/`, `app/lib/features/scan/` |
| **B** | IoT: sensor probe | Build the probe (ESP32, sensors, BLE/Wi-Fi), train the sensor model, stream data to the phone, co-design the fusion layer | `firmware/`, `models/sensor_branch/`, `app/lib/features/sensor/` |
| **C** | Deployment: compression and on-phone optimization | Quantization and pruning, export to a mobile runtime (TensorFlow Lite), benchmark latency and throughput on a real phone, own the app shell and model inference call | `models/compressed/`, `benchmarks/`, `app/lib/core/`, `app/lib/features/comparison/` |
| **D** | AI: explainability and fairness | Grad-CAM and SHAP / feature attribution, cross-dataset generalization, performance by Fitzpatrick type and class rarity, consent and onboarding flow | `models/explainability/`, `results/`, `app/lib/features/explain/`, `app/lib/features/onboarding/` |

The fusion model (`models/fusion/`) is co-owned by A and B, then handed to C for compression.

## 5. Repository structure

```text
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
│   │   │   ├── scan/          # [A] Camera capture, result, per-class panel
│   │   │   ├── sensor/        # [B] Probe pairing, sensor capture, status panel
│   │   │   ├── comparison/    # [C] Original vs compressed panel
│   │   │   ├── explain/       # [D] Grad-CAM overlay, fairness-gap chart
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
| --- | --- |
| Model training | Python, TensorFlow / Keras |
| Compression and export | TensorFlow Lite (quantization, pruning) |
| Explainability | Grad-CAM, SHAP |
| Sensor probe | ESP32, BLE / Wi-Fi |
| Phone app | Flutter, `tflite_flutter`, BLE package |
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

**Primary deliverable:** the FairScope system, a phone app paired with the IoT sensor probe.

In a live panel evaluation, the system demonstrates:

1. Touching the probe to the skin and taking a phone photo
2. Real-time fused image and sensor classification with confidence and Grad-CAM explanation
3. Live comparison of the compressed vs full model running on the phone
4. Fairness-gap analysis across skin tones, with and without sensor fusion

**Extra deliverable:** a browser dashboard that mirrors the app's research views for larger screens.

## 11. Git workflow

1. **`main`:** Production/demo-ready branch. Used for supervisor reviews and milestone evaluations. Nobody pushes to `main` directly.
2. **`develop`:** Primary integration branch. All ongoing feature branches are merged here first.
3. **Feature branches:** Create a branch per task off `develop`: `type/area-short-description` (e.g., `feat/compression-quantization`, `feat/sensor-ble-pairing`, `fix/comparison-panel-crash`).
4. **Pull requests:** Open PRs targeting the `develop` branch. At least one teammate reviews and approves before merging.
5. **Releases to `main`:** Before milestone reviews, ensure all tests pass on `develop`, then merge `develop` into `main` with a release tag (e.g., `v1.0-milestone`).
6. **Sync often:** Regularly pull updates from `develop` into your feature branch to avoid merge conflicts.
7. **Code ownership:** Work within your assigned subsystem folders. For changes in another member's area, consult them or open a PR for review.

**Large files:** Do not commit datasets or heavy model weights. Use Git LFS or external releases for large files. Never commit secrets, passwords, or personal test photos.

## 12. Ethics

- Only public, de-identified datasets are used for training and evaluation.
- Images captured during testing require participant consent and are never committed.
- Fairness results are reported honestly, including gaps between skin types.
- FairScope is a research prototype, not a medical diagnostic device.

## 13. Project status

| Area | Owner | Status |
| --- | --- | --- |
| Image branch and rare-class detection | A | Not started |
| Sensor probe hardware | B | Not started |
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
| --- | --- | --- |
| A | | |
| B | | |
| C | | |
| D | | |

Supervisor:
