-- 01_export_labeling_sheet.sql
-- Makes the blank sheet for hand-labeling 300 products with the codebook.
--
-- Sample: 300 products from analysis_products, picked by sorting on a
--   hash of each product_id. Same 300 every time, on any computer.
-- Split: the first 100 are "dev" (for tuning the AI prompt), the other
--   200 are "test" (for measuring the AI once, at the end).
-- Price is left out on purpose: label from name, brand, and type only.
--
-- Writes to human_labels_BLANK.csv so a rerun can never overwrite your
-- finished labels. Rename your filled-in copy to human_labels.csv.

COPY (
    WITH sample AS (
        SELECT product_id, brand_name, description, type
        FROM analysis_products
        ORDER BY md5(product_id || 'labels-v1')
        LIMIT 300
    )
    SELECT product_id,
           brand_name,
           description,
           type,
           NULL::VARCHAR AS subtype,
           NULL::VARCHAR AS material,
           NULL::VARCHAR AS fabric,
           NULL::VARCHAR AS pattern,
           NULL::VARCHAR AS finish,
           NULL::VARCHAR AS collab_partner,
           NULL::VARCHAR AS staple_or_statement,
           NULL::VARCHAR AS notes
    FROM sample
    ORDER BY split, product_id
) TO 'data/labels/human_labels_BLANK.csv' (HEADER);
