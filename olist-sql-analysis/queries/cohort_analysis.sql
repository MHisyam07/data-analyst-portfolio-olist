-- Customer Cohort Analysis
-- Analisis cohort untuk memahami retensi pelanggan berdasarkan bulan pertama pembelian.
WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
customer_orders AS (
    SELECT 
        o.customer_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        fp.cohort_month
    FROM orders o
    JOIN first_purchase fp USING(customer_id)
)
SELECT 
    cohort_month,
    order_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_orders
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;