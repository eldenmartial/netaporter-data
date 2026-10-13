WITH materials(material) AS (
    VALUES ('cotton'), ('leather'), ('wool'), ('silk'), ('cashmere'),
           ('linen'), ('suede'), ('faux'), ('down'), ('shearling'),
           ('feather'), ('merino'), ('rubber'), ('modal'), ('tencel'),
           ('lyocell'), ('pvc'), ('mohair'), ('pima'), ('alpaca'),
           ('fur'), ('hair'), ('ramie'), ('ecovero')
),
names AS (
    SELECT product_id, type,
           regexp_replace(LOWER(description), 'button[- ]down', 'buttondown', 'g') AS name
    FROM products
),
matches AS (
    SELECT n.product_id, n.type, m.material
    FROM names n
    JOIN materials m
      ON regexp_matches(n.name, '\b' || m.material || '\b')
),
per_material AS (
    SELECT material,
           COUNT(DISTINCT product_id)                                 AS n_products,
           COUNT(DISTINCT product_id) FILTER (WHERE type = 'clothing') AS n_clothing,
           COUNT(DISTINCT product_id) FILTER (WHERE type = 'shoes')    AS n_shoes
    FROM matches
    GROUP BY material
),
no_material AS (
    SELECT 'NO MATERIAL STATED'                      AS material,
           COUNT(*)                                  AS n_products,
           COUNT(*) FILTER (WHERE type = 'clothing') AS n_clothing,
           COUNT(*) FILTER (WHERE type = 'shoes')    AS n_shoes
    FROM products
    WHERE product_id NOT IN (SELECT product_id FROM matches)
)
SELECT material,
       n_products,
       ROUND(100.0 * n_products / (SELECT COUNT(*) FROM products), 1) AS pct_of_products,
       n_clothing,
       n_shoes
FROM (SELECT * FROM per_material
      UNION ALL
      SELECT * FROM no_material)
ORDER BY material = 'NO MATERIAL STATED',   -- puts the coverage row last
         n_products DESC;
