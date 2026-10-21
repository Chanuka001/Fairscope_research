# FairScope App (Flutter)

Android phone app for **FairScope**, a multimodal facial skin condition analysis system. A wireless probe (ESP32-CAM with an OV2640 camera, plus skin sensors) captures a face image and sensor readings and sends them to the phone. The phone runs one compressed fusion model on-device, shows the result and an explanation, and has a research view of the model's performance.

This README is the working spec for the app. If you are an AI coding agent, read **Section 11 (Agent rules)** first.

---

## 1. Current version: scope

This is the **progress-presentation version** (about 50% of Member C's component: compression and deployment).

**In scope**
- Flutter app that runs on a real Android phone
- App shell: 2 tabs (Analyse, History), nested navigation for the 4-step flow, theme, state management
- On-device inference with a **stand-in TFLite model** in two variants: float32 (original) and int8 (compressed)
- Benchmark service and the performance dashboard with real measured numbers
- `ProbeService` interface with a **mock** (connection animation, bundled test images, fake sensor readings)
- Image preprocessing (decode JPEG, crop, resize, normalize)
- Pending capture cards, History (analysed scans only)

**Not in scope yet**
- The real fusion model (Members A and B are still training it)
- Real probe communication (Member B builds the firmware); mocked for now
- Real Grad-CAM and fairness data (Member D); placeholders for now
- iOS, cloud backend, user accounts, web dashboard

**Important**
- The stand-in model is NOT a skin-condition model. Every screen that shows its output is labelled **"Placeholder model"**.
- The camera is on the probe (ESP32-CAM + OV2640), not the phone. The app never uses the phone camera.

---

## 2. App flow

Two bottom tabs: **Analyse** and **History**. Inside Analyse, the user moves through a 4-step flow. Back and forward both work. The bottom tabs are hidden inside steps 2 to 4, replaced by a back button and a step indicator.

```
Step 1: Connect + captures
   probe powers on, phone auto-connects (animation: connecting → connected)
   user presses the device button → capture arrives as a card
   card actions: View raw data | Delete | Analyse
        │ Analyse
        ▼
Step 2: Result summary
   capture data + prediction summary ("Placeholder model") + [Explain] button
        │ Explain
        ▼
Step 3: Explanation (Grad-CAM)
   heatmap overlay, plain-language explanation
   [Model performance] button (research view, not part of the real-world app)
        │ Model performance
        ▼
Step 4: Performance dashboard
   original (fp32) vs compressed (int8): size, latency, accuracy
   later: per-class accuracy, fairness across skin tones
```

- **Back from step 2** returns to step 1 (probe connected, cards still there).
- **History tab:** lists analysed scans. Opening one loads the same steps 2 to 4 with back and forward.

### Rules for captures
- The probe **pushes** a capture when the user presses its button. The app does not request photos.
- Up to **5 pending capture cards** on step 1, newest on top. The oldest is dropped when a sixth arrives. Pending cards are kept in memory and cleared when the app closes.
- **Delete** removes a capture completely (pending or in History). Ask for confirmation, or offer undo.
- **Only analysed captures go to History.** Unanalysed captures are never saved.
- **View raw data** shows what the phone received: sensor values, image size in bytes, resolution, timestamp, transfer time.

### History records
- Auto-generated ID (for example `FS-0001`) and an optional user label.
- The label field must say: "Do not enter real names."
- Stored: image, sensor values, timestamp, prediction, timings, model variant.
- Stored only in the app's private storage on the phone. No cloud. Delete means delete.
- Consent wording for saved face images is Member D's and the supervisor's to confirm.

---

## 3. Architecture

Three layers. UI never talks to the model, storage or the probe directly; it goes through services.

```
┌──────────────────────────────────────────────────────────┐
│ 1. UI LAYER          lib/features/                       │
│    analyse/ (connect, result, explain, performance)      │
│    history/  onboarding/                                 │
├──────────────────────────────────────────────────────────┤
│ 2. SERVICE LAYER     lib/core/services/ + lib/core/state/│
│    ProbeService        CaptureStore     HistoryRepository│
│    ImagePreprocessor   ModelRunnerService                │
│    BenchmarkService    ResultsRepository  ExplainService │
├──────────────────────────────────────────────────────────┤
│ 3. MODEL LAYER       assets/models/                      │
│    baseline_fp32.tflite   quantized_int8.tflite          │
└──────────────────────────────────────────────────────────┘

Probe (ESP32-CAM) ──► ProbeService ──► CaptureStore ──► ImagePreprocessor ──► ModelRunnerService ──► HistoryRepository
```

### Services

| Service | Owner | Status in this version |
|---|---|---|
| `ProbeService` | Interface and mock: C. Real implementation: Member B | Mock only |
| `CaptureStore` | C | Real (in memory, max 5 pending) |
| `HistoryRepository` | C | Real (JSON + image files in private app storage) |
| `ImagePreprocessor` | C, steps confirmed by the image-model owner | Real: JPEG decode, crop, resize, normalize |
| `ModelRunnerService` | C | Real (`tflite_flutter`) |
| `BenchmarkService` | C | Real (inference, preprocessing, transfer, total timing) |
| `ResultsRepository` | C | Loads sample JSON from assets |
| `ExplainService` | Member D | Placeholder (dummy heatmap) |

Each service is an **abstract class** plus implementations, so a mock swaps for the real one without UI changes.

`ProbeService` provides:
- `connectionStatus`: a stream of `off`, `connecting`, `connected`, `lost`, `error` (drives the connecting animation)
- `captures`: a stream of `Capture` objects pushed when the device button is pressed
- `connect()` / `disconnect()`

### Data classes
- `SensorReading`: moisture, temperature, color_index, timestamp
- `Capture`: temporary id, JPEG bytes, `SensorReading`, received time, transfer time
- `ScanRecord`: `FS-xxxx` id, optional label, capture data, prediction, timings, model variant, created time
- `Prediction`: label, confidence

### State
`lib/core/state/` (Riverpod) holds the connection status, pending captures, the **selected record** being viewed in steps 2 to 4 (a new analysis or one opened from History), and the benchmark results. Use Riverpod only.

---

## 4. Folder structure

```
app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── services/        # abstract interfaces + implementations + mocks
│   │   ├── state/           # Riverpod providers
│   │   ├── models/          # data classes (SensorReading, Capture, ScanRecord, Prediction, BenchmarkResult)
│   │   ├── config/          # model_config.dart, probe_config.dart
│   │   ├── navigation/      # tabs, nested navigators, step indicator
│   │   └── theme/
│   ├── features/
│   │   ├── analyse/
│   │   │   ├── connect/     # [B + C] step 1: probe status, capture cards
│   │   │   ├── result/      # [A + C] step 2: result summary
│   │   │   ├── explain/     # [D] step 3: Grad-CAM explanation
│   │   │   └── performance/ # [C, with A and D panels] step 4
│   │   ├── history/         # [C]
│   │   └── onboarding/      # [D]
│   └── shared/              # reusable widgets, utils
├── assets/
│   ├── models/              # .tflite files + labels.txt
│   ├── test_images/         # sample face images for the mock probe
│   └── sample_results/      # placeholder JSON for panels
├── test/
└── pubspec.yaml
```

---

## 5. Screens

| Screen | Owner | This version |
|---|---|---|
| Onboarding / consent | D | Placeholder with an "I agree" button that unlocks the app |
| Step 1: Connect + captures | B (probe widgets), C (cards, state) | Mock probe with connection animation, capture cards, raw data view |
| Step 2: Result summary | A (result widgets), C | Prediction summary, "Placeholder model" tag, Explain button |
| Step 3: Explanation | D | Placeholder heatmap and explanation text, button to step 4 |
| Step 4: Performance dashboard | **C** | fp32 vs int8: size, latency, speedup; sample accuracy and fairness panels labelled "Sample data" |
| History | C | List of analysed scans, search by ID or label, open, rename, delete |

**Step 1 states:** probe off or not connected, connecting (animation), connected with no captures, capturing or transferring, captures received (cards), transfer failed, probe lost.

**Mock device button:** in mock mode, show a visible "Simulate device button" control so a capture can be triggered without hardware. Hide it when the real probe is used.

---

## 6. Probe interface (draft, to confirm with Member B)

Open questions for Member B:
- **Connection:** BLE gives the earbuds-style auto-connect, but an OV2640 JPEG over BLE is slow. Options: BLE for pairing and sensor data with the image over Wi-Fi, or everything over Wi-Fi. BLE and Wi-Fi share one radio on the ESP32, so running both at once may cause drops.
- **Push model:** the device pushes a capture when its button is pressed.
- **Image settings:** resolution and JPEG quality (suggested start: 640x480 or 800x600).
- **Time:** use the phone's receive time or a probe timestamp.

When agreed, record the final protocol here and in `lib/core/config/probe_config.dart`.

---

## 7. Model contract (stand-in)

Keep this in `lib/core/config/model_config.dart` so swapping in the real fusion model is a config change.

| Item | Value |
|---|---|
| Files | `assets/models/baseline_fp32.tflite`, `assets/models/quantized_int8.tflite` |
| Labels | `assets/models/labels.txt` |
| Input | One image, 224 x 224 x 3 (confirm from the actual model file) |
| Normalization | Check the model's expected range and document it here |
| Output | Class probabilities |

Always read tensor shapes and types from the interpreter at runtime and log them on startup. The int8 model may use different input and output types than fp32; handle both explicitly.

**Real fusion model (later):** takes image + sensor vector, outputs class probabilities. Shapes, normalization, class order and filenames are agreed with Members A and B and recorded here.

**Image source note:** real inputs will be OV2640 images (low-quality sensor, color cast, JPEG artifacts). Preprocessing must match training, and accuracy should be tested on real probe images, since the difference from training data can lower accuracy for reasons unrelated to compression.

---

## 8. Benchmark method

Used by `BenchmarkService` and shown on the performance dashboard (step 4).

**Model comparison (the main result)**
- Same input, same device, same conditions for both models
- 5 to 10 warm-up runs (not counted), then at least 50 timed runs
- Time **only the interpreter call**
- Report mean, median, min, max and standard deviation (milliseconds)
- Report model file size (MB) from the asset
- Record device model and Android version

**Pipeline timing (extra result)**
- `transfer_ms`: image received from the probe
- `preprocess_ms`: decode, crop, resize, normalize
- `inference_ms`: interpreter call (the only number used in the fp32 vs int8 comparison)
- `total_ms`: capture to result
- Never mix transfer or preprocessing time into the model latency comparison

**Not measured in-app**
- **Memory:** measure with Android Studio Profiler or `adb shell dumpsys meminfo` and add the result to the JSON by hand
- **Accuracy:** computed offline on a test set and shown from JSON; never computed live

Result JSON (saved on the device and copied to `benchmarks/` in the repo root):

```json
{
  "device": "Device name",
  "android_version": "14",
  "date": "YYYY-MM-DD",
  "model_version": "standin_mobilenet",
  "probe": "mock",
  "runs": 50,
  "warmup_runs": 10,
  "pipeline_ms": { "transfer_mean": null, "preprocess_mean": 0.0, "total_mean": null },
  "variants": [
    {
      "name": "baseline_fp32",
      "size_mb": 0.0,
      "latency_ms": { "mean": 0.0, "median": 0.0, "min": 0.0, "max": 0.0, "std": 0.0 },
      "peak_ram_mb": null,
      "accuracy_overall": null,
      "accuracy_rare": null
    },
    {
      "name": "quantized_int8",
      "size_mb": 0.0,
      "latency_ms": { "mean": 0.0, "median": 0.0, "min": 0.0, "max": 0.0, "std": 0.0 },
      "peak_ram_mb": null,
      "accuracy_overall": null,
      "accuracy_rare": null
    }
  ]
}
```

Use `null` for values not measured yet. With the mock probe, `transfer_mean` stays `null`.

---

## 9. Performance rules

- Run image decoding, preprocessing and inference off the UI thread (isolate)
- Update only the widget showing live values; never rebuild whole screens per reading
- Handle errors visibly: model failed to load, probe unreachable, transfer failed, probe lost, storage full
- Benchmarks only count on a real phone in profile or release mode; show a warning on the dashboard in debug mode or on an emulator

---

## 10. Packages

Check the latest version and open issues on pub.dev before adding each one.

- `tflite_flutter` (inference)
- `flutter_riverpod` (state)
- `http` or `dio` (probe over Wi-Fi, when the real probe is added)
- `image` (JPEG decode, crop, resize)
- `path_provider` (private app storage for History)
- `permission_handler`
- `fl_chart` (charts)

Not used: the `camera` package. A BLE package is chosen by Member B only if the team uses BLE.

---

## 11. Agent rules (read before coding)

1. **One task at a time.** Do exactly the task in the prompt, then stop.
2. **Do not invent APIs.** For `tflite_flutter` and other packages, use only methods in the installed version's documentation. If unsure, say so.
3. **Do not add packages** that are not listed in Section 10 without asking.
4. **Follow the architecture.** UI calls services; services call models. No model, storage, network or hardware code inside widgets.
5. **Use abstract interfaces and mocks** for anything not built yet (probe, explain).
6. **Do not use the phone camera.** Images come only from `ProbeService`.
7. **Only analysed captures are saved.** Deleting means deleting, with no hidden copies.
8. **Do not edit other members' folders** beyond placeholder screens.
9. **Label placeholders** on screen: "Placeholder model", "Sample data", "Mock data".
10. **Explain what you changed** at the end of each task: files created, files edited, how to run it.
11. **Keep code simple and readable.**
12. **After each task the app must run** with `flutter run` without errors. If something fails, report it.

---

## 12. Task list

Each task ends with the app running and a Git commit.

| # | Task | Done when |
|---|---|---|
| 1 | Project structure per Section 4, Riverpod, theme from design tokens, 2 tabs (Analyse, History) with nested navigators and placeholder screens for steps 1 to 4, step indicator | Tabs switch, steps move forward and back, tabs hidden in steps 2 to 4 |
| 2 | Onboarding placeholder with consent button | First launch shows onboarding, then the app |
| 3 | Data classes and abstract service interfaces (Section 3) | Compiles, documented |
| 4 | `MockProbeService` (connection states with animation timings, capture stream, "Simulate device button") and `CaptureStore` (max 5) | Simulated button press adds a card, sixth drops the oldest |
| 5 | Step 1 UI: connection card with animation, capture cards with View raw data, Delete (confirm), Analyse | All step 1 states work with the mock |
| 6 | Add stand-in fp32 model, implement `ModelRunnerService` and `ImagePreprocessor`, run one inference | Prediction and tensor shapes logged |
| 7 | Step 2 result summary: Analyse runs the model, shows summary labelled "Placeholder model", Explain button | Mock capture goes to a result |
| 8 | Add the int8 model, handle its types | Both variants run on the same image |
| 9 | Step 3 **minimal** Explain: placeholder heatmap, button to step 4 | Full flow works end to end |
| 10 | `BenchmarkService` per Section 8 | Returns stats for both variants |
| 11 | Step 4 performance dashboard: run benchmark, fp32 vs int8 table, speedup, size, save result JSON, debug and emulator warning | Real numbers shown and saved |
| 12 | Polish Explain screen (heatmap overlay, opacity slider, explanation text, sample fairness chart labelled "Sample data") | Matches the design |
| 13 | `HistoryRepository` and History tab: save on analyse, auto ID, optional label, list, search, open (loads steps 2 to 4), rename, delete | Analysed scans persist; deleted ones are gone |
| 14 | Polish: error, loading and empty states | No crashes on probe loss or missing files |
| 15 | `HttpProbeService` or BLE implementation against the real probe once Section 6 is agreed | Real captures reach the app |

---

## 13. Run and test

```bash
flutter doctor            # all checks should pass
flutter devices           # phone must be listed (USB debugging on)
cd app
flutter pub get
flutter run               # run on the phone
flutter test              # unit tests
```

Benchmarks must be run on a **real phone** with `flutter run --profile`, not on an emulator or in debug mode.

---

## 14. Git workflow

- Branch per task: `feat/app-shell`, `feat/mock-probe`, `feat/performance-dashboard`
- Commit after each working step with a clear message
- Open a pull request into `main`; another member reviews
- Never commit datasets, personal images, keys or passwords
- Large model files: use Git LFS or GitHub Releases

---

## 15. Handoff to teammates

When the shell and the mock probe work, tell the team:
- **Member B:** the `ProbeService` interface and Section 6 (connection method, push model, image settings)
- **Members A and B (models):** the preprocessing steps and Section 7; ask for real OV2640 test images
- **Member D:** the `ExplainService` interface, where `explain/` and `onboarding/` live, and the History consent question
- **Everyone:** the result JSON format in Section 8