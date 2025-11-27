-- Monthly Revenue
-- Menghitung pendapatan bulanan untuk melihat tren pertumbuhan Olist dari waktu ke waktu.
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price + oi.freight_value) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Top 10 Product Categories by Revenue
-- Mengidentifikasi kategori produk dengan kontribusi revenue terbesar.
SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer Repeat Rate
-- Mengukur persentase pelanggan yang melakukan pembelian berulang (repeat customers).
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS repeat_rate_percentage
FROM (
    SELECT customer_unique_id, COUNT(order_id) AS order_count
    FROM customers
    JOIN orders on customers.customer_id = orders.customer_id
    GROUP BY customer_unique_id
) t;

-- Orders by State
-- Mengetahui persebaran demand berdasarkan wilayah (state) untuk analisis pasar regional.
SELECT
    customer_state,
    COUNT(order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY total_orders DESC;

-- Top 10 Sellers by Revenue
-- Menemukan seller dengan penjualan tertinggi untuk evaluasi performa merchant.
SELECT
    seller_id,
    SUM(price) AS revenue
FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- Average Review Score per Category
-- Menilai kualitas kategori produk berdasarkan rata-rata review pelanggan.
SELECT
    p.product_category_name,
    AVG(r.review_score) AS avg_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_score DESC;

-- Average Delivery Days
-- Mengukur rata-rata waktu pengiriman untuk mengevaluasi efisiensi logistik.
SELECT
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 0) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered';

-- Late Delivery Percentage
-- Menghitung persentase pesanan yang terlambat untuk memantau reliabilitas pengiriman.
SELECT
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*) * 100 AS late_percentage
FROM orders
WHERE order_status = 'delivered';





