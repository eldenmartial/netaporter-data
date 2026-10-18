
COPY (
    WITH banded AS (
        SELECT a.subtype || ', ' || a.material AS product,
               a.subtype,
               a.material,
               p.type,
               CASE WHEN p.price_usd < 250  THEN 1
                    WHEN p.price_usd < 500  THEN 2
                    WHEN p.price_usd < 1000 THEN 3
                    WHEN p.price_usd < 2500 THEN 4
                    WHEN p.price_usd < 5000 THEN 5
                    ELSE 6 END AS band_order
        FROM netaporter.products p
        JOIN netaporter.product_attributes a USING (product_id)
        WHERE a.material <> 'not stated'
    ),
    bands(band_order, price_band) AS (
        VALUES (1, '1. Under $250'), (2, '2. $250-499'), (3, '3. $500-999'),
               (4, '4. $1,000-2,499'), (5, '5. $2,500-4,999'), (6, '6. $5,000+')
    ),
    products_list AS (
        SELECT product, ANY_VALUE(subtype) AS subtype, ANY_VALUE(material) AS material,
               ANY_VALUE(type) AS type, COUNT(*) AS product_total
        FROM banded
        GROUP BY product
    ),
    grid AS (
        -- every product x every band, including empty ones
        SELECT l.product, l.subtype, l.material, l.type, l.product_total,
               b.band_order, b.price_band, COUNT(x.product) AS n_products
        FROM products_list l
        CROSS JOIN bands b
        LEFT JOIN banded x
               ON x.product = l.product AND x.band_order = b.band_order
        GROUP BY ALL
    ),
    shares AS (
        SELECT *,
               ROUND(100.0 * n_products / product_total, 1) AS pct_of_product,
               LAG(100.0 * n_products / product_total)  OVER w AS pct_below,
               LEAD(100.0 * n_products / product_total) OVER w AS pct_above
        FROM grid
        WINDOW w AS (PARTITION BY product ORDER BY band_order)
    )
    SELECT product, subtype, material, type, product_total,
           band_order, price_band, n_products, pct_of_product,
           COALESCE(product_total >= 50
                    AND pct_below IS NOT NULL AND pct_above IS NOT NULL  -- never the end bands
                    AND LEAST(pct_below, pct_above) >= 5
                    AND pct_of_product < 0.5 * LEAST(pct_below, pct_above), false) AS is_gap
    FROM shares
    ORDER BY product_total DESC, band_order
) TO 'data/price_ladder.csv' (HEADER);