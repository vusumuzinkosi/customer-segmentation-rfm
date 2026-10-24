-- Step 9 | 03: What each K-means segment is worth, from the transactions
-- Joins the segment labels from Step 7 back to every purchase line.

WITH segment_tx AS (
    SELECT s.segment, t.*
    FROM transactions AS t
    JOIN segments AS s USING (customer_id)
),
last_date AS (
    SELECT max(invoice_date) AS d FROM transactions
)
SELECT
    segment,
    count(DISTINCT customer_id)                                  AS customers,
    count(DISTINCT invoice)                                      AS orders,
    round(count(DISTINCT invoice) / count(DISTINCT customer_id), 1) AS orders_per_customer,
    round(sum(revenue) / count(DISTINCT invoice), 0)             AS avg_order_value,
    round(sum(revenue), 0)                                       AS revenue,
    round(100 * sum(revenue) / sum(sum(revenue)) OVER (), 1)     AS pct_of_revenue,
    -- revenue in the last 90 days of data: who is still buying now?
    round(sum(revenue) FILTER (WHERE invoice_date > (SELECT d FROM last_date) - INTERVAL 90 DAY), 0) AS revenue_last_90_days
FROM segment_tx
GROUP BY segment
ORDER BY revenue DESC;
