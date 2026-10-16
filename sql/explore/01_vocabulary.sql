-- 01_vocabulary.sql
-- Question: Which words appear most often in product names?
-- Feeds: the codebook (subtype, material, finish lists), not a report chart
-- Method: split each name into words at anything that isn't a letter
--   (spaces, hyphens, "+"), keeping accented letters so words like
--   "bouclé" stay whole. Count products, not appearances, so a word
--   repeated within one name counts once.
-- Words in fewer than 30 products are left out; they're too rare to support a category in the price analysis.
 
WITH words AS (
    SELECT product_id,
           unnest(regexp_split_to_array(LOWER(description), '[^a-zà-ÿ]+')) AS word
    FROM products
)
SELECT word,
       COUNT(DISTINCT product_id) AS n_products
FROM words
WHERE length(word) > 2          -- drops fragments like "t" from "T-Shirt"
GROUP BY word
HAVING COUNT(DISTINCT product_id) >= 30
ORDER BY n_products DESC, word;