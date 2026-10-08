initial checks/parsing data (initialchecks.py)

- Shape of the data. Lists the column names and their types, counts the rows, and counts missing values in each column.
- Product types. Lists every value in type, with a count and median price for each.
- Brand coverage. Counts how many brands have at least 20 products, and how many products those brands cover. Brand premiums need enough items per brand to be reliable, so this tells us how much data survives a minimum cutoff.
    - Also lists top 30 brands, can check whether certain brands are in it
- Shows the 50 most and 50 least expensive items.
- Repeated descriptions. Finds products with the same brand and name listed more than once, and compares their prices. If the repeats have slightly different prices, like sneakers at $505 and $530, they're probably colorways. If the prices are identical, they may be true duplicates.
- Collaborations. Counts product names starting with "+", the marker in "+ Off-White Air Force 1." If there are only a few dozen, the collab question becomes a side note rather than a full sub-question.
- Random sample. Prints 50 random products for us to read ourselves. This shows how consistently the names follow a pattern like "[model] [material] [product]," which determines how well the AI extraction in week 3 will work. The sample is fixed by a seed (REPEATABLE (42)), so we see the same 50 items every time we run it.

