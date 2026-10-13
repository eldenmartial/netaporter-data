INSERT INTO product_attributes BY NAME
SELECT * REPLACE ('ai' AS label_source)
FROM read_csv('data/labels/final_product_labels.csv');