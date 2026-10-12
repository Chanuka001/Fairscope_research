# Results

Owned by **Members A & D**. Stores evaluation outputs, fairness audits, and per-class performance records across skin tones.

## Fairness & Per-Class Metrics Format

Results are output as JSON files (e.g. `results/fairness_eval_<model_version>.json`):

- **Per-class performance:** Precision, Recall, F1-score, and ROC-AUC for both common and rare skin condition classes.
- **Fairness metrics:** Disparate impact, equal opportunity differences, and subgroup accuracy broken down across Fitzpatrick skin types I through VI, comparing vision-only models against fused multimodal models.
