-- 02_clean.sql
-- Clean the raw rows in stages. Each stage is its own table so you
-- can inspect exactly what a step did, and each one writes a line
-- to cleaning_log.

------------------------------------------------------------------
-- DECISIONS: edit these after reviewing your Phase 0 output,
-- and record the reasoning in decisions.md.
------------------------------------------------------------------

-- Which product types are in scope. Check the "Every product type"
-- section of your Phase 0 output and add or remove values.
CREATE TABLE scope_types (type VARCHAR);
INSERT INTO scope_types VALUES ('clothing'), ('shoes');

-- Brand spellings to merge. Empty for now. If 04_checks.sql finds
-- near-duplicate brand names, add them here, for example:
--   INSERT INTO brand_aliases VALUES ('A.P.C.', 'APC'), ('A.P.C', 'APC'), ('Apc', 'APC');
CREATE TABLE brand_aliases (raw_name VARCHAR, canonical_name VARCHAR);

------------------------------------------------------------------
-- Step 2: normalize text
-- Trim spaces at the ends, collapse repeated spaces, uppercase
-- brands, lowercase types, then apply brand_aliases.
------------------------------------------------------------------
CREATE TABLE stage_normalized AS
WITH trimmed AS (
    SELECT raw_id,
           UPPER(regexp_replace(TRIM(brand), '\s+', ' ', 'g'))  AS brand_trimmed,
           regexp_replace(TRIM(description), '\s+', ' ', 'g')    AS description,
           price_usd,
           LOWER(TRIM(type))                                     AS type,
           brand       AS brand_original,
           description AS description_original
    FROM raw_products
)
SELECT t.raw_id,
       COALESCE(a.canonical_name, t.brand_trimmed) AS brand,
       t.description,
       t.price_usd,
       t.type,
       t.brand_original,
       t.description_original
FROM trimmed t
LEFT JOIN brand_aliases a ON a.raw_name = t.brand_trimmed;

INSERT INTO cleaning_log
SELECT 2, 'Normalize text',
       (SELECT COUNT(*) FROM raw_products), COUNT(*),
       SUM(CASE WHEN brand IS DISTINCT FROM brand_original
                  OR description IS DISTINCT FROM description_original
                THEN 1 ELSE 0 END),
       'Trimmed and collapsed spaces, uppercased brands, lowercased types, merged brand aliases. No rows removed; rows_affected = rows whose brand or description text changed'
FROM stage_normalized;

------------------------------------------------------------------
-- Step 3: drop incomplete rows
------------------------------------------------------------------
CREATE TABLE stage_complete AS
SELECT * FROM stage_normalized
WHERE brand IS NOT NULL AND brand <> ''
  AND description IS NOT NULL AND description <> ''
  AND price_usd IS NOT NULL
  AND type IS NOT NULL AND type <> '';

INSERT INTO cleaning_log
SELECT 3, 'Drop incomplete rows',
       (SELECT COUNT(*) FROM stage_normalized), COUNT(*),
       (SELECT COUNT(*) FROM stage_normalized) - COUNT(*),
       'Missing brand, description, price, or type; these cannot be analyzed'
FROM stage_complete;

------------------------------------------------------------------
-- Step 4: drop invalid prices
------------------------------------------------------------------
CREATE TABLE stage_valid_price AS
SELECT * FROM stage_complete
WHERE price_usd > 0;

INSERT INTO cleaning_log
SELECT 4, 'Drop invalid prices',
       (SELECT COUNT(*) FROM stage_complete), COUNT(*),
       (SELECT COUNT(*) FROM stage_complete) - COUNT(*),
       'Price of zero or below is a placeholder, not a real retail price'
FROM stage_valid_price;

------------------------------------------------------------------
-- Step 5: keep in-scope product types
------------------------------------------------------------------
CREATE TABLE stage_in_scope AS
SELECT * FROM stage_valid_price
WHERE type IN (SELECT type FROM scope_types);

INSERT INTO cleaning_log
SELECT 5, 'Keep in-scope types',
       (SELECT COUNT(*) FROM stage_valid_price), COUNT(*),
       (SELECT COUNT(*) FROM stage_valid_price) - COUNT(*),
       'Kept: ' || (SELECT string_agg(type, ', ' ORDER BY type) FROM scope_types)
       || '. Other categories (e.g. watches, fine jewelry, home) are priced on different logic'
FROM stage_in_scope;
