-- Step 9 | 01: Clean the raw transactions in SQL
-- Same rules as notebooks/01_clean.ipynb, written as one query.
-- Input:  raw_transactions (every invoice line, as loaded from the Excel file)
-- Output: transactions (real purchases by known customers, with revenue)

CREATE OR REPLACE TABLE transactions AS
WITH deduplicated AS (
    -- exact duplicate lines are double-recorded, keep one copy
    SELECT DISTINCT * FROM raw_transactions
)
SELECT
    Invoice                      AS invoice,
    InvoiceDate                  AS invoice_date,
    CAST("Customer ID" AS INTEGER) AS customer_id,
    Country                      AS country,
    StockCode                    AS stock_code,
    Description                  AS description,
    Quantity                     AS quantity,
    Price                        AS price,
    Quantity * Price             AS revenue
FROM deduplicated
WHERE "Customer ID" IS NOT NULL                -- purchase must belong to a customer
  AND NOT starts_with(Invoice, 'C')            -- cancellations
  AND NOT starts_with(Invoice, 'A')            -- bad-debt adjustments
  AND regexp_matches(StockCode, '^\d{5}')      -- real products only (no POST, M, fees)
  AND Quantity > 0
  AND Price > 0;
