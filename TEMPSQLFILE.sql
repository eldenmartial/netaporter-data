CREATE OR REPLACE TABLE product_attributes AS
SELECT product_id,
       subtype,
       material,
       fabric,
       pattern,
       finish,
       NULLIF(collab_partner, '') AS collab_partner
FROM read_csv('data/labels/final_product_attributes.csv', all_varchar = true);