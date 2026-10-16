# FairScope App (Flutter)

Android phone app for **FairScope**, a multimodal facial skin condition analysis system (camera image + IoT sensor probe, fused by one on-device model).

This README is the working spec for the app. If you are an AI coding agent, read **Section 9 (Agent rules)** first.

---

## 1. Current version: scope

This is the **progress-presentation version** (about 50% of Member C's component: compression and deployment).

**In scope**
- Flutter app that runs on a real Android phone
- App shell: navigation, theme, state management, placeholder screens
- On-device inference with a **stand-in TFLite model** in two variants: float32 (original) and int8 (compressed)
- Benchmark service and a comparison screen with real measured numbers
- Service interfaces and mocks so teammates can plug in their parts

**Not in scope yet**
- The real fusion model (Members A and B are still training it)
- Real BLE probe communication (Member B), mocked for now
- Real Grad-CAM and fairness data (Member D), placeholders for now
- iOS, cloud backend, user accounts, web dashboard

**Important:** the stand-in model is NOT a skin-condition model. Every screen that shows its output must be labelled **"Placeholder model"**.

---

## 2. Architecture

Three layers. UI never talks to the model or hardware directly; it goes through services.

```
┌──────────────────────────────────────────────────────────┐
│ 1. UI LAYER          lib/features/                       │
│    scan/ sensor/ comparison/ explain/ onboarding/        │
├──────────────────────────────────────────────────────────┤
│ 2. SERVICE LAYER     lib/core/services/ + lib/core/state/│
│    ModelRunnerService  BenchmarkService                  │
│    SensorBleService    CameraService                     │
│    ResultsRepository   ExplainService                    │
├──────────────────────────────────────────────────────────┤
│ 3. MODEL LAYER       assets/models/                      │
│    baseline_fp32.tflite   quantized_int8.tflite          │
└──────────────────────────────────────────────────────────┘
```

### Services

| Service | Owner | Status in this version |
|---|---|---|
| `ModelRunnerService` | Member C | Real implementation (`tflite_flutter`) |
| `BenchmarkService` | Member C | Real implementation |
| `ResultsRepository` | Member C | Loads JSON from assets/storage; sample data |
| `SensorBleService` | Interface and mock: C. Real BLE: B | Mock only |
| `CameraService` | Interface: C + A. Probe/phone capture: A | Probe micro-camera stream or phone camera capture |
| `ExplainService` | Member D | Placeholder (returns Grad-CAM overlay and fairness audit) |

Each service is an **abstract class** plus one or more implementations, so a mock can be swapped for the real one without changing UI code. (e.g., swapping phone camera for probe-mounted micro-camera stream).

### Shared state

`lib/core/state/` holds a `CurrentScan` object used by all screens:
- captured image
- sensor reading
- timestamp
- prediction (label, confidence)
- model variant used (fp32 or int8)

Use **Riverpod** for state management. Do not mix in other state libraries.

---

## 3. Folder structure

```
app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── services/        # abstract interfaces + implementations + mocks
│   │   ├── state/           # Riverpod providers, CurrentScan
│   │   ├── models/          # plain data classes (Reading, Prediction, BenchmarkResult)
│   │   ├── config/          # model_config.dart (the model contract)
│   │   ├── navigation/      # shell, bottom nav, routes
│   │   └── theme/
│   ├── features/
│   │   ├── scan/            # [A]
│   │   ├── sensor/          # [B]
│   │   ├── comparison/      # [C]
│   │   ├── explain/         # [D]
│   │   └── onboarding/      # [D]
│   └── shared/              # reusable widgets, utils
├── assets/
│   ├── models/              # .tflite files + labels.txt
│   └── sample_results/      # placeholder JSON for panels
├── test/
└── pubspec.yaml
```

---

## 4. Screens

Bottom navigation with 4 tabs, plus a first-launch onboarding flow.

| Screen | Owner | This version |
|---|---|---|
| Onboarding / consent | D | Placeholder screen with an "I agree" button that unlocks the app |
| Scan | A | Probe targeting, capture, condition prediction, with direct link to Explain screen ("Placeholder model" label) |
| Sensor | B | Shows live fake readings from the mock service, probe connection status & telemetry |
| Comparison | **C** | Runs fp32 vs int8 on the same input, shows latency, file size, speedup, and JSON persistence |
| Explain | D | Grad-CAM heatmap with opacity control and cross-population fairness chart across Fitzpatrick types |

Every placeholder screen shows the owner (for example "Member D: explainability, coming soon").

---

## 5. Model contract (stand-in)

Keep all of this in `lib/core/config/model_config.dart` so swapping in the real fusion model is a config change.

**Stand-in model:** a small pretrained image classifier (MobileNet-style) exported to TFLite.

| Item | Value |
|---|---|
| Files | `assets/models/baseline_fp32.tflite`, `assets/models/quantized_int8.tflite` |
| Labels | `assets/models/labels.txt` |
| Input | One image, 224 x 224 x 3 (confirm from the actual model file) |
| Normalization | Check the model's expected range (0-1, -1 to 1, or 0-255) and document it here |
| Output | Class probabilities |

Always read tensor shapes and types from the interpreter at runtime, and log them on startup. The int8 model may use different input and output types than the fp32 one; handle both explicitly.

**Real fusion model (later):** takes image + sensor vector, outputs class probabilities. Input shapes, normalization, class order and filenames will be agreed with Members A and B and recorded here.

---

## 6. Benchmark method

Used by `BenchmarkService` and shown on the comparison screen.

- Same input, same device, same conditions for both models
- 5 to 10 warm-up runs (not counted), then at least 50 timed runs
- Time **only the interpreter call**; record preprocessing time separately
- Report mean, median, min, max and standard deviation (milliseconds)
- Report model file size (MB) from the asset
- Record device model and Android version
- **Memory:** do not claim in-app memory numbers. Measure with Android Studio Profiler or `adb shell dumpsys meminfo` and add the result to the JSON by hand
- **Accuracy:** computed offline on a test set, shown from JSON. Never computed live

Result JSON (saved to the device and copied to `benchmarks/` in the repo root):

```json
{
  "device": "Device name",
  "android_version": "14",
  "date": "YYYY-MM-DD",
  "model_version": "standin_mobilenet",
  "runs": 50,
  "warmup_runs": 10,
  "variants": [
    {
      "name": "baseline_fp32",
      "size_mb": 0.0,
      "latency_ms": { "mean": 0.0, "median": 0.0, "min": 0.0, "max": 0.0, "std": 0.0 },
      "preprocess_ms_mean": 0.0,
      "peak_ram_mb": null,
      "accuracy_overall": null,
      "accuracy_rare": null
    },
    {
      "name": "quantized_int8",
      "size_mb": 0.0,
      "latency_ms": { "mean": 0.0, "median": 0.0, "min": 0.0, "max": 0.0, "std": 0.0 },
      "preprocess_ms_mean": 0.0,
      "peak_ram_mb": null,
      "accuracy_overall": null,
      "accuracy_rare": null
    }
  ]
}
```

Use `null` for values not measured yet.

---

## 7. Performance rules

- Run image preprocessing and inference off the UI thread (isolate) so the UI stays smooth
- Update only the widget showing live values (for example sensor readings); never rebuild whole screens per reading
- Pair the photo and the sensor reading using timestamps; do not rely on arrival order
- Handle errors visibly: model failed to load, camera permission denied, probe disconnected

---

## 8. Packages

Check the latest version and open issues on pub.dev before adding each one.

- `tflite_flutter` (inference)
- `flutter_riverpod` (state)
- `camera` (capture)
- `permission_handler`
- `path_provider`
- `fl_chart` (charts)

BLE package (`flutter_blue_plus` or `flutter_reactive_ble`) is Member B's decision. Do not add one in this version.

---

## 9. Agent rules (read before coding)

1. **One task at a time.** Do exactly the task in the prompt, then stop.
2. **Do not invent APIs.** For `tflite_flutter` and other packages, use only methods that exist in the installed version's documentation. If unsure, say so instead of guessing.
3. **Do not add packages** that are not listed in Section 8 without asking.
4. **Follow the architecture.** UI calls services; services call models. No model or hardware code inside widgets.
5. **Use abstract interfaces and mocks** for anything not built yet (sensor, explain).
6. **Do not edit other members' folders** beyond placeholder screens.
7. **Label placeholders.** Anything fake must say so on screen.
8. **Explain what you changed** at the end of each task: files created, files edited, how to run it.
9. **Keep code simple and readable.** No unnecessary abstractions or clever tricks.
10. **After each task the app must run** with `flutter run` without errors. If something fails, report it instead of hiding it.

---

## 10. Task list

Do these in order. Each task ends with the app running on a real phone and a Git commit.

| # | Task | Done when |
|---|---|---|
| 1 | Create project structure per Section 3, set up Riverpod, theme, bottom navigation with 4 placeholder tabs | App runs, tabs switch, each shows its owner label |
| 2 | Onboarding placeholder with consent button that unlocks the app | First launch shows onboarding, then the main shell |
| 3 | Define data classes and abstract service interfaces (`ModelRunnerService`, `BenchmarkService`, `SensorBleService`, `CameraService`, `ResultsRepository`, `ExplainService`) | Compiles, interfaces documented with comments |
| 4 | Implement `SensorBleService` mock (fake readings stream) and show it on the Sensor tab | Live fake values update without rebuilding the whole screen |
| 5 | Add the stand-in fp32 model, implement `ModelRunnerService`, run one inference on a bundled test image | Prediction and tensor shapes logged and shown |
| 6 | Add the int8 model; handle its input/output types | Both variants run on the same image |
| 7 | Implement `BenchmarkService` per Section 6 | Returns timing stats for both variants |
| 8 | Build the Comparison screen (run benchmark, show fp32 vs int8 table, speedup, size) and save the result JSON | Real numbers displayed and saved |
| 9 | Basic camera capture on the Scan tab feeding the model, with "Placeholder model" label | Take a photo, see a prediction |
| 10 | `ResultsRepository` with sample JSON; placeholder chart and heatmap on the Explain tab | Sample data shown, clearly labelled |
| 11 | Polish: error states, loading indicators, empty states | No crashes on permission denial or missing files |

---

## 11. Run and test

```bash
flutter doctor            # all checks should pass
flutter devices           # phone must be listed (USB debugging on)
cd app
flutter pub get
flutter run               # run on the phone
flutter test              # unit tests
```

Benchmarks must be run on a **real phone**, in release or profile mode (`flutter run --profile`), not on an emulator or in debug mode. Debug mode is much slower and gives misleading numbers.

---

## 12. Git workflow

- Branch per task: `feat/app-shell`, `feat/model-runner`, `feat/benchmark-screen`
- Commit after each working step with a clear message
- Open a pull request into `main`; another member reviews
- Never commit datasets, personal images, keys or passwords
- Large model files: if they are too big for git, use Git LFS or GitHub Releases

---

## 13. Handoff to teammates

When the shell works, tell the team:
- **A:** where `scan/` lives and the `CameraService` interface (what it must return)
- **B:** the `SensorBleService` interface and the reading data class, so the real BLE code can replace the mock
- **D:** the `ExplainService` interface and where `explain/` and `onboarding/` live
- **Everyone:** the model contract in Section 5 and the result JSON format in Section 6