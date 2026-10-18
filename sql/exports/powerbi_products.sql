-- powerbi_products.sql
-- One flat table for Power BI: one row per product with brand, price,
-- labels, flags, positioning group, and price-ladder columns.
-- Needs data/price_ladder.csv (from sql/exports/price_ladder.sql) to exist.
-- Run:  duckdb data/netaporter.duckdb < sql/exports/powerbi_products.sql

COPY (
    SELECT p.product_id,
           b.brand_name,
           b.parent_brand,
           p.type,
           p.description,
           p.price_usd,
           a.subtype,
           a.material,
           a.fabric,
           a.pattern,
           a.finish,
           a.collab_partner IS NOT NULL                 AS is_collab,
           p.description ILIKE '%NET SUSTAIN%'          AS is_sustainable,
           COALESCE(bp.positioning_group, 'unlabeled')  AS positioning_group,
           b.n_products >= 20                           AS in_analysis_set,
           -- price-ladder columns for the Recommendation page
           a.subtype || ', ' || a.material              AS ladder_product,
           CASE WHEN p.price_usd < 250  THEN '1. Under $250'
                WHEN p.price_usd < 500  THEN '2. $250-499'
                WHEN p.price_usd < 1000 THEN '3. $500-999'
                WHEN p.price_usd < 2500 THEN '4. $1,000-2,499'
                WHEN p.price_usd < 5000 THEN '5. $2,500-4,999'
                ELSE '6. $5,000+' END                   AS price_band,
           COALESCE(a.subtype || ', ' || a.material IN (
               SELECT product FROM read_csv('data/price_ladder.csv')
               WHERE CAST(is_gap AS VARCHAR) = 'true'
           ), false)                                    AS has_price_gap
    FROM products p
    JOIN brands b USING (brand_id)
    LEFT JOIN product_attributes a ON a.product_id = p.product_id
    LEFT JOIN read_csv('data/labels/brand_positioning.csv') bp ON bp.brand_id = b.brand_id
) TO 'data/powerbi_products.csv' (HEADER);
