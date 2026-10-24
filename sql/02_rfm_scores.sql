-- Step 9 | 02: RFM per customer, scored 1 to 5 with window functions
-- Same idea as notebooks/02_rfm.ipynb, but in SQL.

CREATE OR REPLACE TABLE rfm AS
WITH snapshot AS (
    -- the day after the last sale, so the most recent buyer has recency 0
    SELECT date_trunc('day', max(invoice_date)) + INTERVAL 1 DAY AS snapshot_date
    FROM transactions
),
per_customer AS (
    SELECT
        customer_id,
        -- whole days since the last order (same as pandas Timedelta.days)
        date_diff('second', max(invoice_date), (SELECT snapshot_date FROM snapshot)) // 86400 AS recency,
        count(DISTINCT invoice) AS frequency,
        round(sum(revenue), 2)  AS monetary
    FROM transactions
    GROUP BY customer_id
),
scored AS (
    SELECT
        *,
        6 - NTILE(5) OVER (ORDER BY recency, customer_id) AS R,  -- most recent fifth gets 5
        NTILE(5) OVER (ORDER BY frequency, customer_id)   AS F,  -- most orders gets 5
        NTILE(5) OVER (ORDER BY monetary, customer_id)    AS M   -- highest spend gets 5
    FROM per_customer
)
SELECT
    *,
    R + F + M AS rfm_score,
    CASE WHEN R + F + M <= 6  THEN 'Bronze'
         WHEN R + F + M <= 11 THEN 'Silver'
         ELSE 'Gold' END AS tier
FROM scored
ORDER BY customer_id;
