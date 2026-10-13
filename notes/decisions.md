initial checks/parsing data (initialchecks.py)

- Shape of the data. Lists the column names and their types, counts the rows, and counts missing values in each column.
- Product types. Lists every value in type, with a count and median price for each.
- Brand coverage. Counts how many brands have at least 20 products, and how many products those brands cover. Brand premiums need enough items per brand to be reliable, so this tells us how much data survives a minimum cutoff.
    - Also lists top 30 brands, can check whether certain brands are in it
- Shows the 50 most and 50 least expensive items.
- Repeated descriptions. Finds products with the same brand and name listed more than once, and compares their prices. If the repeats have slightly different prices, like sneakers at $505 and $530, they're probably colorways. If the prices are identical, they may be true duplicates.
- Collaborations. Counts product names starting with "+", the marker in "+ Off-White Air Force 1." If there are only a few dozen, the collab question becomes a side note rather than a full sub-question.
- Random sample. Prints 50 random products for us to read ourselves. This shows how consistently the names follow a pattern like "[model] [material] [product]," which determines how well the AI extraction in week 3 will work. The sample is fixed by a seed (REPEATABLE (42)), so we see the same 50 items every time we run it.


build_db

- leaving out accessories and bags. “Accessories” is a catch-all of belts, sunglasses, wallets, jewelry, and hats, with very different materials and prices. Comparable products inside it are hard to define, so it’s the category most likely to add noise.
- keeping clothing and shoes. Categories are priced on different logic, so each is modeled separately. Clothing is the main analysis; shoes serve as the robustness check and source of the sneaker comparison. Accessories and bags are excluded because they mix unrelated product types with no clear basis for comparing them. 

- IDs are hashes, not row numbers. Each product_id is a short code generated from the brand, description, and type. Rebuilding the database gives every product the same ID, so your week 3 hand labels and AI labels, which will live in files, always reattach to the right product.
- Keys enforce correctness. PRIMARY KEY means no two rows can share an ID. REFERENCES (a foreign key) means a product can’t point to a brand that doesn’t exist. Mistakes cause errors instead of passing silently.
- The analysis set is a view, not a deletion. Small brands stay in the database but are left out of modeling. Changing the cutoff means editing one number and rebuilding.
- Decisions live in tables. scope_types and brand_aliases hold your choices as data, so anyone reading the database can see exactly what was decided.

vocabulary

- rough draft of sorting terms based on descriptions, help of llm, scanned with own fashion judgement
- phrases:
    - Dress length is the biggest subtype decision. Midi, mini, and maxi dresses together make up about 3,400 products. The simplest choice is to merge them into “dress” and record length as its own field (mini / midi / maxi / none). That keeps subtypes clean, and length becomes something you can test for a price effect separately. Skirts follow the same pattern.-
    - Trims appear constantly: leather-, lace-, satin-, and feather-trimmed together come to about 900 products. This confirms you need the rule that trim isn’t the main material. A “Leather-Trimmed Cotton Dress” is cotton with a trim finish.-
    - Materials often come as a pair, material plus fabric: cotton poplin, silk satin, silk crepe. The rule from your draft works here. Material is the fiber (cotton, silk); fabrictype is the weave or knit (poplin, satin, crepe).
    - “Shell” is outerwear, not a finish. The phrases “shell down” and “quilted shell” show that “shell” means a jacket’s outer fabric. In the word list it was labeled finish, so move it to other.
    - Sustainability shows up in several forms: NET SUSTAIN, organic cotton, and recycled stretch fabrics. That’s more evidence the is_sustainable flag would work, built from any of those signals.
- 
