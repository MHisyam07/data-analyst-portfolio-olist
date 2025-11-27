-- Late Delivery by City
-- Mengidentifikasi kota dengan jumlah keterlambatan pengiriman tertinggi.
SELECT c.customer_city, COUNT(*) AS late_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE order_delivered_customer_date > order_estimated_delivery_date
GROUP BY customer_city
ORDER BY late_orders;

-- Seller Ranking per Product Category
-- Merangking seller terbaik dalam tiap kategori produk berdasarkan revenue.
SELECT
    oi.seller_id,
    SUM(oi.price) AS revenue,
    p.product_category_name,
    RANK() OVER(PARTITION BY p.product_category_name ORDER BY SUM(oi.price) DESC) AS seller_rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name, oi.seller_id;

-- Monthly Cumulative Revenue
-- Menghitung akumulasi revenue bulan ke bulan untuk memantau pertumbuhan kumulatif Olist.
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(o.order_purchase_timestamp, "%y-%m") AS month,
           SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY month
)
SELECT
    month, revenue,
    SUM(revenue) OVER(ORDER BY month) AS monthly_cumulative
FROM monthly_revenue;

-- Top 1% Highest-Value Customers (VIP)
-- Mengidentifikasi pelanggan dengan pengeluaran tertinggi (top 1%) untuk strategi customer segmentation.
WITH total_spend AS (
    SELECT o.customer_id,
           SUM(oi.price) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY customer_id
),
ranked AS (
    SELECT customer_id,
           total_spent,
           PERCENT_RANK() OVER(ORDER BY total_spent) AS p_rank
    FROM total_spend
)
SELECT *
FROM ranked
WHERE p_rank >= 0.99
ORDER BY total_spent DESC;