-- ====================================================================
-- PROJECT: OLIST E-COMMERCE ANALYSIS
-- AUTHOR: [MOCHAMMAD HISYAM]
-- ====================================================================

-- 1. DATA EXPLORATION (EDA)
--    Memahami Rentang Data & Distribusi Status
SELECT 
    MIN(order_purchase_timestamp) as first_order,
    MAX(order_purchase_timestamp) as last_order,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT customer_id) as total_customers
FROM olist_orders_dataset;

-- 2. Mencari Top 10 Order dengan Nilai Tertinggi
SELECT 
    o.order_id,
    o.order_status,
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM-DD') as purchase_date,
    SUM(oi.price) as total_value
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY 1, 2, 3
ORDER BY total_value DESC
LIMIT 10;


-- 3. Analisis Performa Penjualan & Keterlambatan per State
-- (Menggabungkan JOIN 3 tabel + Logika Bisnis Keterlambatan)
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) as total_transactions,
    SUM(oi.price) as revenue,
    -- Menghitung % Keterlambatan
    ROUND(
        (SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)::DECIMAL / 
        COUNT(o.order_id)) * 100
    , 2) as late_delivery_rate
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY late_delivery_rate DESC;

-- 4. Analisis Preferensi Metode Pembayaran
-- Mengidentifikasi tipe pembayaran yang paling banyak digunakan dan kontribusinya terhadap revenue
SELECT 
    p.payment_type,
    COUNT(p.order_id) as total_usage,
    SUM(p.payment_value) as total_payment_value,
    ROUND(SUM(p.payment_value) * 100.0 / SUM(SUM(p.payment_value)) OVER(), 2) as percentage_of_revenue
FROM olist_order_payments_dataset p
GROUP BY 1
ORDER BY total_payment_value DESC;

-- 5. Melihat Hubungan Durasi Pengiriman vs Rating
-- Menunjukkan hubungan performa logistik dengan kepuasan pelanggan
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On-Time'
        ELSE 'Late'
    END as delivery_status,
    ROUND(AVG(r.review_score), 2) as avg_review_score,
    COUNT(*) as total_reviews
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1;

-- 6. Pareto Analysis: Ranking Kategori Kontributor Revenue Terbesar
-- (Menggunakan Ranking & Filtering Window Function)
WITH CategoryRevenue AS (
    SELECT 
        COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') as category,
        SUM(oi.price) as revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
    GROUP BY 1
)
SELECT 
    *,
    RANK() OVER(ORDER BY revenue DESC) as rank_position,
    SUM(revenue) OVER(ORDER BY revenue DESC ROWS BETWEE	N UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
FROM CategoryRevenue
LIMIT 20;

-- 7. Customer Segmentation Analysis (RFM Approach)
-- Skill: Logic Bisnis Kompleks, CTE, Window Functions, Date Diff
-- Tujuan: Mengelompokkan user berdasarkan Recency (Kapan terakhir belanja) & Monetary (Total uang)

WITH CustomerMetrics AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) as last_purchase_date,
        COUNT(DISTINCT o.order_id) as frequency,
        SUM(oi.price) as total_spent,
        -- Mencari tanggal order terakhir di SELURUH dataset sebagai acuan "Hari Ini"
        MAX(MAX(o.order_purchase_timestamp)) OVER() as dataset_max_date
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
Segmentation AS (
    SELECT 
        customer_unique_id,
        frequency,
        total_spent,
        -- Hitung Recency: Berapa hari sejak belanja terakhir sampai tanggal max dataset
        EXTRACT(DAY FROM (dataset_max_date - last_purchase_date)) as recency_days
    FROM CustomerMetrics
)
SELECT 
    customer_unique_id,
    recency_days,
    total_spent,
    -- LOGIKA SEGMENTASI
    CASE 
        WHEN recency_days <= 90 AND total_spent > 500 THEN 'VIP / Champion'
        WHEN recency_days <= 90 AND total_spent <= 500 THEN 'Active User'
        WHEN recency_days BETWEEN 91 AND 270 AND total_spent > 500 THEN 'Loyal - Need Attention'
        WHEN recency_days > 270 THEN 'Churned / Inactive'
        ELSE 'Others'
        END as customer_segment
FROM Segmentation
ORDER BY total_spent DESC
LIMIT 20; -- Sampel contoh





