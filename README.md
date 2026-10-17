# Where Does Luxury Price Come From?

**At Net-a-Porter, who made it matters more than what it is.** The same wool coat ranges from $500 to $7,600 depending on the label, a 15× gap. Within a single luxury house, going from flats to a gown changes the price only about 6×.

An analysis of 19,090 Net-a-Porter womenswear products, asking how much of a luxury item's price comes from the brand and how much from the product itself.

**[View the report](https://app.powerbi.com/view?r=eyJrIjoiNzFmM2RiNmUtMzBjMy00M2Y0LWJlYWMtMGMxN2Y3ZWZiZGI5IiwidCI6ImY2YjZkZDViLWYwMmYtNDQxYS05OWEwLTE2MmFjNTA2MGJkMiIsImMiOjZ9)** 

Tools: SQL (DuckDB), Python (pandas, scikit-learn), Excel, Power BI

---

## Key findings

### 1. Brand moves price more than product type

I held one factor fixed and measured how much price varies with the other: the same product across brands, and the same brand across products. Spread is the most expensive median divided by the least expensive.

| Same product, different brands | Most expensive | Least expensive | Spread |
|---|---|---|---|
| Leather boots | Loro Piana, $2,450 | Sorel, $200 | 12× |
| Wool coat | Valentino Garavani, $7,600 | The Frankie Shop, $500 | 15× |
| Silk dress | Valentino Garavani, $5,500 | Baserange, $130 | 42× |
| **Typical (median)** | | | **15×** |

| Same brand, different products | Most expensive | Least expensive | Spread |
|---|---|---|---|
| Gucci | gown, ~$7,250 | mules, ~$930 | 7.8× |
| The Row | gown, ~$4,950 | sneakers, ~$800 | 6.2× |
| Saint Laurent | coat, ~$5,250 | flats, ~$920 | 5.7× |
| **Typical (median)** | | | **6.2×** |

Products were the three most common product-and-material combinations; brands were three of the largest by product count. Power BI's Key influencers analysis points the same way: most of the strongest price drivers are individual brands (Oscar de la Renta, Valentino Garavani, Brunello Cucinelli), with gowns, coats, and shearling the leading product factors.

### 2. Sustainable pieces aren't discounted; they come from cheaper brands

At first glance, NET SUSTAIN products look much cheaper than regular ones of the same type (a sustainable trench coat has a median of about $2,100 vs. $3,200). But comparing each brand against itself, the gap almost disappears:

| Within-brand comparison | Result |
|---|---|
| Brand-and-product-type groups compared | 64 |
| Sustainable products covered | 506 |
| Median price ratio (sustainable ÷ regular) | 0.96 |
| Groups where the sustainable version is cheaper | 59% |

Sustainable pieces cost about 4% less than the same brand's regular pieces of the same type, a difference too small to call real. They look cheaper overall because they mostly come from lower-priced brands. The data can't say *why* prices are the same (for example, whether brands absorb higher production costs), only that they are.

### 3. Prices follow brand positioning

I placed each major brand into a positioning group based on my own read of the brand, without looking at prices. Median prices still line up with those groups: heritage luxury leads at about $1,600, quiet luxury follows at about $1,190, and specialty categories (swimwear, denim, lingerie, sportswear) sit under $350.

### 4. Warmth and structure cost the most

Shearling (~$2,700) and down (~$1,500) are the most expensive materials, quilted or padded the most expensive finish, and heavy woven fabrics like jacquard and tweed beat light knits like jersey and mesh. Much of this reflects outerwear being expensive rather than the material alone.

---

## Data

- **Source:** [Net-a-Porter product dataset](https://www.kaggle.com/datasets/justinpakzad/net-a-portermr-porter-fashion-dataset) from Kaggle, used under its license terms. No data was scraped.
- **Fields:** brand, product name, retail price (USD), category.
- **Scope:** clothing and shoes, 19,090 products. Accessories and bags were excluded because they mix unrelated product types with no clear basis for comparison.
- **Snapshot:** a single point in time, so the data shows listed retail prices, not sales or discounts.

Raw data is not included in this repo. See [`data/data_dictionary.md`](data/data_dictionary.md) for every table and column.

---

## Methods

### 1. Database and cleaning (SQL)

The raw CSV is loaded into DuckDB and normalized into four tables: `brands`, `products`, `product_attributes`, and `brand_positioning`. Cleaning runs in stages, each one logged with rows before, rows after, and the reason ([`notes/cleaning_log.md`](notes/cleaning_log.md)):

- normalize brand names and whitespace
- drop incomplete rows and invalid prices
- keep in-scope categories
- collapse repeated listings (likely colorways) to their median price

Product IDs are hashes of brand, name, and category, so they stay stable across rebuilds and labels always reattach to the right product. The whole database rebuilds from scratch with one command.

### 2. A codebook from the data

Product names hold details like material and finish only as free text. I counted every word and two-word phrase across all names ([`sql/explore/`](sql/explore/)), sorted the vocabulary into categories, and wrote a codebook defining each field, its allowed values, and rules for edge cases ([`notes/codebook.md`](notes/codebook.md)). For example, trims don't count as the main material: a "Leather-Trimmed Cotton Dress" is cotton.

### 3. Labeling and validation

An LLM labeled each product's subtype, material, fabric, pattern, finish, and collaboration partner, following the codebook. To check it, I hand-labeled 300 randomly sampled products using only the brand, name, and category (never the price), split into 100 dev products for refining the prompt and 200 held-out test products used once at the end.

**Test-set agreement (200 products):**

| Field | Accuracy | Cohen's kappa | 95% range |
|---|---|---|---|
| Pattern | 1.00 | 1.00 | 1.00 – 1.00 |
| Subtype | 0.98 | 0.97 | 0.95 – 0.99 |
| Finish | 0.96 | 0.93 | 0.89 – 0.97 |
| Collaboration partner | 1.00 | 0.89 | 0.50 – 1.00 |
| Material | 0.88 | 0.85 | 0.79 – 0.90 |
| Fabric | 0.80 | 0.76 | 0.69 – 0.83 |
| Staple vs. statement | 0.68 | 0.38 | 0.26 – 0.49 |

Mean kappa across the seven fields: **0.83**. Kappa measures agreement beyond chance (0 = guessing, 1 = perfect); ranges are bootstrapped ([`src/evaluate_labels.py`](src/evaluate_labels.py)).

**The AI reads products well but not taste.** Agreement was strong on objective attributes but weak on staple vs. statement, where the AI consistently called pieces staples that I judged statement pieces (54 cases vs. 11 the other way). That field is excluded from the price analysis.

**Tuning inflates scores.** Agreement was higher on the dev products the prompt was refined on than on the held-out test products (fabric dropped from 0.93 to 0.76), which is why only test-set numbers are reported.

[Model and version used: MODEL NAME, DATE. Prompt: `prompts/FINAL-PROMPT-FILE`.]

### 4. Analysis

- **Brand vs. product:** price spreads across brands for a fixed product vs. across products for a fixed brand (finding 1), supported by Power BI Key influencers.
- **Sustainability:** median price of NET SUSTAIN vs. regular products within the same brand and subtype, limited to groups with at least 3 of each.
- **Positioning:** median price by positioning group and by brand.

All charts in the report use medians, since luxury prices are heavily skewed.

---

## Limitations

- **Spread comparisons are approximate.** They use a handful of examples and extreme values, so they show direction and scale, not exact shares. A regression separating brand and product effects is the natural next step ([`src/brand_vs_product.py`](src/brand_vs_product.py)).
- **Labels come from product names only.** About 41% of names don't state a material; those are labeled "not stated" rather than guessed.
- **Agreement is measured against one labeler (me).** A second human labeler would show how much people disagree, setting a realistic ceiling for the AI.
- **One retailer, one point in time.** Results describe Net-a-Porter's assortment and listed prices, not the whole luxury market or what items actually sold for.
- **Positioning groups reflect my own judgment** and are presented as such.

---

## Repository structure

```
├── README.md
├── decisions.md              every judgment call, dated, with reasoning
├── data/
│   ├── data_dictionary.md    tables, columns, and definitions
│   └── labels/               hand labels, AI labels, brand positioning
├── notes/
│   ├── codebook.md           labeling rules
│   └── cleaning_log.md       generated by the build
├── prompts/                  labeling prompts, versioned
├── sql/
│   ├── 01_load_raw.sql       build pipeline, run in order
│   ├── 02_clean.sql
│   ├── 03_build_tables.sql
│   ├── 04_checks.sql
│   ├── 05_load_labels.sql
│   ├── explore/              vocabulary, phrases, materials
│   ├── analysis/             queries behind the charts
│   ├── labels/               labeling-sheet exports
│   └── exports/              Power BI export
├── src/
│   ├── build_db.py           rebuilds the database from scratch
│   ├── run_queries.py        runs a folder of queries, saves CSVs
│   ├── evaluate_labels.py    accuracy, kappa, confusion matrices
│   ├── rule_labeler.py       keyword-based labeler (comparison baseline)
│   ├── brand_vs_product.py   regression decomposition (next step)
│   └── make_charts.py
└── report/                   PDF of the Power BI report
```

---

## Reproduce

```bash
python -m venv .venv
source .venv/bin/activate
pip install duckdb pandas scikit-learn matplotlib

# 1. Put the Kaggle CSV at data/raw/netaporter.csv, then build the database
python src/build_db.py

# 2. Run the exploration and analysis queries
python src/run_queries.py sql/explore
python src/run_queries.py sql/analysis

# 3. Check label agreement on the held-out test set
python src/evaluate_labels.py data/labels/ai_labels.csv test

# 4. Export for Power BI
duckdb data/netaporter.duckdb < sql/exports/powerbi_products.sql
```