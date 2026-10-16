-- 02_phrases.sql
-- Question: Which two-word phrases appear most often in product names?
-- Feeds: the codebook, especially two-word subtypes ("ankle boots")
--   and material + fabric pairs ("silk satin")
-- Method: split each name into a list of words, then pair each word
--   with the one after it. range(1, len(words)) gives the positions
--   1 to n-1, so words[i + 1] always exists.
-- Pairs containing a connector word ("and", "the", "de") are
-- left out, since they're fragments of longer phrases
-- ("off the shoulder", "crepe de chine").

WITH names AS (
    SELECT product_id,
           list_filter(regexp_split_to_array(LOWER(description), '[^a-zà-ÿ]+'),
                       x -> x <> '') AS words
    FROM products
),
pairs AS (
    SELECT product_id,
           words[i]     AS first_word,
           words[i + 1] AS second_word
    FROM names, range(1, len(words)) AS r(i)
)
SELECT first_word || ' ' || second_word AS phrase,
       COUNT(DISTINCT product_id) AS n_products
FROM pairs
WHERE first_word  NOT IN ('and', 'the', 'de', 'with', 'in', 'a')
  AND second_word NOT IN ('and', 'the', 'de', 'with', 'in', 'a')
GROUP BY phrase
HAVING COUNT(DISTINCT product_id) >= 30
ORDER BY n_products DESC, phrase;
