-- 03_build_tables.sql
-- Build the four final tables from the cleaned rows.
-- IDs are short hashes of the product's identity (brand, description,
-- type) rather than row numbers. That keeps every ID the same each
-- time the database is rebuilt, so your hand labels and AI labels
-- (stored in files) always attach to the right product.


-- brands: one row per brand

CREATE TABLE brands (
    brand_id     VARCHAR PRIMARY KEY,
    brand_name   VARCHAR NOT NULL UNIQUE,
    parent_brand VARCHAR NOT NULL,
    n_products   INTEGER NOT NULL
);

INSERT INTO brands
SELECT left(md5(brand), 10)                              AS brand_id,
       brand                                              AS brand_name,
       -- Group sub-labels under their parent company. Extend as needed.
       CASE WHEN brand LIKE '%RALPH LAUREN%' OR brand = 'RRL'
            THEN 'RALPH LAUREN'
            ELSE brand END                                AS parent_brand,
       COUNT(DISTINCT description || '|' || type)         AS n_products
FROM stage_in_scope
GROUP BY brand;


-- products: one row per unique brand + description + type.
-- Repeated listings (likely colorways) collapse into one product
-- at their median price; the spread is kept for transparency.

CREATE TABLE products (
    product_id  VARCHAR PRIMARY KEY,
    brand_id    VARCHAR NOT NULL REFERENCES brands(brand_id),
    description VARCHAR NOT NULL,
    type        VARCHAR NOT NULL,
    price_usd   DOUBLE  NOT NULL,
    n_listings  INTEGER NOT NULL,
    price_min   BIGINT  NOT NULL,
    price_max   BIGINT  NOT NULL,
    is_collab   BOOLEAN NOT NULL
);

INSERT INTO products
SELECT left(md5(brand || '|' || description || '|' || type), 12) AS product_id,
       left(md5(brand), 10)          AS brand_id,
       description,
       type,
       MEDIAN(price_usd)             AS price_usd,
       COUNT(*)                      AS n_listings,
       MIN(price_usd)                AS price_min,
       MAX(price_usd)                AS price_max,
       description LIKE '+%'         AS is_collab
FROM stage_in_scope
GROUP BY brand, description, type;

INSERT INTO cleaning_log
SELECT 6, 'Collapse repeated listings',
       (SELECT COUNT(*) FROM stage_in_scope), COUNT(*),
       SUM(CASE WHEN n_listings > 1 THEN n_listings ELSE 0 END),
       'Same brand + description + type listed more than once (likely colorways, no color column). Collapsed to median price; rows_affected = listings merged'
FROM products;


-- product_attributes: filled in week 3.
-- One row per product per label source, so your hand labels and
-- the AI's labels sit side by side for measuring agreement.

CREATE TABLE product_attributes (
    product_id          VARCHAR NOT NULL REFERENCES products(product_id),
    label_source        VARCHAR NOT NULL CHECK (label_source IN ('human', 'ai')),
    subtype             VARCHAR,
    material            VARCHAR,
    finish              VARCHAR,
    collab_partner      VARCHAR,
    staple_or_statement VARCHAR CHECK (staple_or_statement IN ('staple', 'statement')),
    model_name          VARCHAR,
    labeled_at          TIMESTAMP,
    PRIMARY KEY (product_id, label_source)
);


-- brand_positioning: your taste labels, filled in week 3.

CREATE TABLE brand_positioning (
    brand_id          VARCHAR PRIMARY KEY REFERENCES brands(brand_id),
    positioning_group VARCHAR NOT NULL,
    rationale         VARCHAR,
    labeled_at        DATE
);


-- analysis_products: the set the models will use.
-- A view, so small brands stay in the database but out of the
-- brand-premium analysis. Change the 20 here if you change the cutoff.

CREATE VIEW analysis_products AS
SELECT p.*, b.brand_name, b.parent_brand
FROM products p
JOIN brands b USING (brand_id)
WHERE b.n_products >= 20;

INSERT INTO cleaning_log
SELECT 7, 'Define analysis set (view)',
       (SELECT COUNT(*) FROM products), COUNT(*),
       (SELECT COUNT(*) FROM products) - COUNT(*),
       'Brands with at least 20 products, enough for a reliable brand premium. Smaller brands stay in the products table'
FROM analysis_products;

-- Remove the intermediate stage tables. raw_products stays so the
-- whole pipeline can be checked against the original.
DROP TABLE stage_normalized;
DROP TABLE stage_complete;
DROP TABLE stage_valid_price;
DROP TABLE stage_in_scope;
