# Benchmarks

Owned by **Member C**. Stores standardized benchmark logs in JSON format for reproducible evaluation.

## Benchmark Schema

Benchmark files follow the naming format: `benchmarks/latency/<YYYY-MM-DD>_<device_name>.json`.

```json
{
  "device": "Google Pixel 7 / Samsung Galaxy S22",
  "date": "2026-10-12",
  "model_version": "fusion_v1",
  "variants": [
    {
      "name": "original_float32",
      "size_mb": 45.2,
      "latency_ms_mean": 128.4,
      "peak_ram_mb": 112.0,
      "accuracy_overall": 0.884,
      "accuracy_rare": 0.742
    },
    {
      "name": "quantized_int8",
      "size_mb": 11.8,
      "latency_ms_mean": 32.1,
      "peak_ram_mb": 38.5,
      "accuracy_overall": 0.871,
      "accuracy_rare": 0.735
    }
  ]
}
```
