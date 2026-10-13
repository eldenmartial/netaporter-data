-- 04_checks.sql
-- Sanity checks on the finished database. Each check begins with a
-- line starting "-- check" plus a colon; src/build_db.py runs and prints each.

-- check: Table sizes
SELECT 'raw_products' AS table_name, COUNT(*) AS rows FROM raw_products
UNION ALL SELECT 'brands', COUNT(*) FROM brands
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'analysis_products (view)', COUNT(*) FROM analysis_products;

-- check: Types removed by the scope decision
SELECT LOWER(TRIM(type)) AS type, COUNT(*) AS rows_removed
FROM raw_products
WHERE LOWER(TRIM(type)) NOT IN (SELECT type FROM scope_types)
GROUP BY 1 ORDER BY rows_removed DESC;

-- check: Possible duplicate brand spellings (add any real ones to brand_aliases)
SELECT regexp_replace(brand_name, '[^A-Z0-9]', '', 'g') AS letters_only,
       string_agg(brand_name, '  |  ') AS spellings
FROM brands
GROUP BY 1 HAVING COUNT(*) > 1;

-- check: Collapsed products with a wide price spread (max > 1.5x min)
SELECT b.brand_name, p.description, p.n_listings, p.price_min, p.price_max
FROM products p JOIN brands b USING (brand_id)
WHERE p.price_max > 1.5 * p.price_min
ORDER BY p.price_max * 1.0 / p.price_min DESC
LIMIT 20;

-- check: Collaborations
SELECT COUNT(*) AS collab_products,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM products), 1) AS pct
FROM products WHERE is_collab;

-- check: Ralph Lauren labels
SELECT brand_name, n_products FROM brands
WHERE parent_brand = 'RALPH LAUREN' ORDER BY n_products DESC;
