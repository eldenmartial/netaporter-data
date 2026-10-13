-- 01_load_raw.sql
-- Load the raw CSV exactly as downloaded. Nothing is changed here.
-- raw_id is the row's position in the file, so any product can be
-- traced back to the rows it came from.

CREATE TABLE raw_products AS
SELECT row_number() OVER () AS raw_id, *
FROM read_csv_auto('data/raw/netaporter.csv');

-- The cleaning log: every step below adds one row describing
-- what changed, how many rows, and why.
CREATE TABLE cleaning_log (
    step_no       INTEGER,
    step          VARCHAR,
    rows_before   BIGINT,
    rows_after    BIGINT,
    rows_affected BIGINT,
    reason        VARCHAR
);

INSERT INTO cleaning_log
SELECT 1, 'Load raw CSV', NULL, COUNT(*), NULL,
       'Original Kaggle file, unchanged'
FROM raw_products;
