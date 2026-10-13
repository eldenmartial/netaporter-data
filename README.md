

## Validating the AI labels

Product names contain the details needed to compare like with like (what an item is, what it's made of, how it's finished), but only as free text. A language model extracts those details into structured fields for all products. Before trusting it, I measured how well it agrees with my own labels.

### Method

1. **Codebook.** I built the label categories from word and phrase counts across all product names (`sql/explore/`), then wrote a codebook defining each field, its allowed values, and rules for edge cases (`notes/codebook.md`). For example, trims don't count as the main material: a "Leather-Trimmed Cotton Dress" is cotton.
2. **Hand labels.** I labeled 300 randomly sampled products myself, using only the brand, product name, and category. I never saw the prices. The sample is reproducible (`sql/labels/01_export_labeling_sheet.sql`).
3. **Dev/test split.** The first 100 products (dev) were used to refine the prompt. The other 200 (test) were held back and used once, after the prompt was final.
4. **AI labels.** Claude Opus labeled the same 300 products using the codebook as its instructions.
5. **Agreement.** For each field I report accuracy and Cohen's kappa, which measures agreement beyond what chance alone would produce (0 = no better than guessing, 1 = perfect). The 95% ranges come from bootstrapping (`src/evaluate_labels.py`).

### Results (test set, 200 products)

| Field | Accuracy | Kappa | 95% range |
|---|---|---|---|
| Pattern | 1.00 | 1.00 | 1.00 – 1.00 |
| Subtype | 0.98 | 0.97 | 0.95 – 0.99 |
| Finish | 0.96 | 0.93 | 0.89 – 0.97 |
| Material | 0.88 | 0.85 | 0.79 – 0.90 |
| Fabric | 0.80 | 0.76 | 0.69 – 0.83 |
| Collaboration partner | 1.00 | 0.89 | 0.50 – 1.00 |
| Staple vs. statement | 0.68 | 0.38 | 0.26 – 0.49 |

### What this shows

**The AI is reliable on objective attributes.** For subtype, pattern, finish, material, and fabric, kappa ranges from 0.76 to 1.00, so these labels are used across the full dataset. Collaborations agree too, but they're rare, so that estimate is uncertain.

**It is not reliable on taste.** Staple vs. statement reached a kappa of only 0.38, and the disagreement runs one way: in 54 test products I judged a piece a statement where the AI called it a staple, against 11 the other way round. The AI sets a much higher bar for what makes a piece trend-driven. Because of this, the AI's staple/statement labels are not used in the price analysis. [Or: are used only as a secondary analysis, with this caveat.]

**Tuning inflates scores, which is why the test set matters.** Agreement was higher on the dev products the prompt was refined on than on the held-out test products. Fabric dropped from 0.93 to 0.76, and staple vs. statement from 0.63 to 0.38. The test numbers above are the honest estimate of how the AI performs on products it hasn't seen.

### Limitations

- Agreement is measured against one labeler (me). A second human labeler would show how much people disagree with each other, which sets a realistic ceiling for the AI.
- 200 test products is enough to estimate common categories well, but rare categories (like collaborations) have wide uncertainty.
- Labels come from product names only. When a name doesn't state a material, it's recorded as "not stated" rather than guessed.

### Reproduce