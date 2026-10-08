"""Initial checks: get to know the dataset before cleaning anything.

Run from the project root:
    python src/initialchecks.py > notes/initialchecks_output.txt
"""
import duckdb

CSV = "data/raw/mrporter.csv"  # change to your file's name
MIN_PRODUCTS_PER_BRAND = 20

con = duckdb.connect()
con.execute(f"CREATE VIEW raw AS SELECT * FROM read_csv_auto('{CSV}')")


def show(title, sql):
    print(f"\n=== {title} ===")
    print(con.sql(sql).df().to_string(index=False))


# 1. Shape of the data
show("Columns and types", "DESCRIBE raw")
show("Row count", "SELECT COUNT(*) AS rows FROM raw")
show("Missing values", """
    SELECT COUNT(*) - COUNT(brand)       AS missing_brand,
           COUNT(*) - COUNT(description) AS missing_description,
           COUNT(*) - COUNT(price_usd)   AS missing_price,
           COUNT(*) - COUNT(type)        AS missing_type
    FROM raw
""")

# VARCHAR means text, so brand, description, and type are text. BIGINT means whole numbers, so prices are whole dollars with no cents.

# 2. Scope: what's in the type column
show("Every product type", """
    SELECT type, COUNT(*) AS n, ROUND(MEDIAN(price_usd)) AS median_price
    FROM raw GROUP BY type ORDER BY n DESC
""")

# 3. Brand coverage: who has enough products for within-brand comparisons
show("Brand coverage", f"""
    SELECT COUNT(*) AS brands,
           SUM(CASE WHEN n >= {MIN_PRODUCTS_PER_BRAND} THEN 1 ELSE 0 END) AS brands_above_min,
           SUM(CASE WHEN n >= {MIN_PRODUCTS_PER_BRAND} THEN n ELSE 0 END) AS products_in_those_brands
    FROM (SELECT brand, COUNT(*) AS n FROM raw GROUP BY brand)
""")
show("Top 30 brands", """
    SELECT brand, COUNT(*) AS n, ROUND(MEDIAN(price_usd)) AS median_price
    FROM raw GROUP BY brand ORDER BY n DESC LIMIT 30
""")
show("Target brands (edit the list)", """
    SELECT brand, COUNT(*) AS n, ROUND(MEDIAN(price_usd)) AS median_price
    FROM raw
    WHERE UPPER(brand) LIKE '%RALPH LAUREN%'
       OR UPPER(brand) LIKE '%LORO PIANA%'
       OR UPPER(brand) LIKE '%BOTTEGA%'
    GROUP BY brand ORDER BY n DESC
""")

# 4. Price extremes: placeholders, typos, or out-of-scope categories?
show("50 most expensive", """
    SELECT brand, description, type, price_usd
    FROM raw ORDER BY price_usd DESC LIMIT 50
""")
show("50 cheapest", """
    SELECT brand, description, type, price_usd
    FROM raw ORDER BY price_usd ASC LIMIT 50
""")

# 5. Repeated descriptions: colorways or true duplicates?
show("Repeated brand + description", """
    SELECT COUNT(*) AS repeated_groups,
           SUM(n) AS rows_involved,
           SUM(CASE WHEN min_p = max_p THEN 1 ELSE 0 END) AS groups_with_same_price
    FROM (SELECT brand, description, COUNT(*) AS n,
                 MIN(price_usd) AS min_p, MAX(price_usd) AS max_p
          FROM raw GROUP BY brand, description HAVING COUNT(*) > 1)
""")
show("Most repeated examples", """
    SELECT brand, description, COUNT(*) AS n,
           MIN(price_usd) AS min_price, MAX(price_usd) AS max_price
    FROM raw GROUP BY brand, description HAVING COUNT(*) > 1
    ORDER BY n DESC LIMIT 15
""")

# 6. Collaborations: enough to analyze?
show("Collaborations (names starting with '+')", """
    SELECT COUNT(*) AS collab_products,
           ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM raw), 1) AS pct_of_all
    FROM raw WHERE TRIM(description) LIKE '+%'
""")

# 7. Read the names yourself: how consistent is the pattern?
show("50 random product names", """
    SELECT brand, description, type, price_usd
    FROM raw USING SAMPLE reservoir(50 ROWS) REPEATABLE (42)
""")
