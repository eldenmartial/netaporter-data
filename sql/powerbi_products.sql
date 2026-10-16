-- powerbi_products.sql
-- One flat table with everything Power BI needs: one row per product,
-- with brand, price, AI/rule labels, flags, and your positioning group.
-- Power BI works best with a single wide table like this.
--

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
           b.n_products >= 20                           AS in_analysis_set
    FROM products p
    JOIN brands b USING (brand_id)
    LEFT JOIN product_attributes a
           ON a.product_id = p.product_id AND a.label_source = 'ai'
    LEFT JOIN read_csv('data/labels/brand_positioning.csv', header = true, all_varchar = true) bp
           ON bp.brand_id = b.brand_id
    ORDER BY b.brand_name, p.price_usd
) TO 'powerbi_products.csv' (HEADER);
