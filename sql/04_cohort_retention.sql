-- Step 9 | 04: Monthly cohort retention
-- Group customers by the month of their first order, then measure what share
-- of each cohort ordered again 1, 2, 3 ... months later.

WITH orders AS (
    SELECT DISTINCT customer_id, date_trunc('month', invoice_date) AS order_month
    FROM transactions
),
first_order AS (
    SELECT customer_id, min(order_month) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
activity AS (
    SELECT
        f.cohort_month,
        date_diff('month', f.cohort_month, o.order_month) AS months_since_first,
        o.customer_id
    FROM orders AS o
    JOIN first_order AS f USING (customer_id)
)
SELECT
    cohort_month,
    months_since_first,
    count(DISTINCT customer_id) AS active_customers,
    round(100 * count(DISTINCT customer_id)
          / max(count(DISTINCT customer_id)) OVER (PARTITION BY cohort_month), 1) AS pct_retained
FROM activity
GROUP BY cohort_month, months_since_first
ORDER BY cohort_month, months_since_first;
