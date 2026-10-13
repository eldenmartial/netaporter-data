-- 02_export_brand_sheet.sql
-- Makes the blank sheet for the brand positioning map.
--
-- Brands: the largest brands in the analysis set (20+ products), in order
--   of size, until together they cover 80% of analysis products.
-- Price is left out on purpose: place each brand from your own read
--   of it, not from what it charges.
--
-- Fill in for each brand:
--   positioning_group: heritage luxury, quiet luxury, fashion-forward designer,
--                      contemporary, or activewear (definitions in the codebook)
--   rationale:         one line on why
--
-- Writes to brand_positioning_BLANK.csv so a rerun can never overwrite
-- your finished labels. Rename your filled-in copy to brand_positioning.csv.

COPY (
    WITH ranked AS (
        SELECT brand_id,
               brand_name,
               parent_brand,
               n_products,
               SUM(n_products) OVER (ORDER BY n_products DESC, brand_name)
                 * 1.0 / SUM(n_products) OVER ()            AS cumulative_share
        FROM brands
        WHERE n_products >= 20
    )
    SELECT brand_id,
           brand_name,
           parent_brand,
           n_products,
           NULL::VARCHAR AS positioning_group,
           NULL::VARCHAR AS rationale
    FROM ranked
    WHERE cumulative_share <= 0.80
       OR cumulative_share - n_products * 1.0 / (SELECT SUM(n_products) FROM brands WHERE n_products >= 20) < 0.80
    ORDER BY n_products DESC, brand_name
) TO 'data/labels/brand_positioning_BLANK.csv' (HEADER);
