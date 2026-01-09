
--		 DATA QUALITY CHECK (PENGECEKAN KUALITAS DATA)

-- 1 Cek Konsistensi Primary Key (Mencari Duplikat)
select order_id, count(*)
from olist_orders_dataset ood
group by order_id
having count(*) > 1;

SELECT customer_id, COUNT(*)
FROM olist_ecommerce.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM olist_ecommerce.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;
-- hasil query ini kosong, berarti data primary key bersih (tidak ada duplikat ID).

-- 2. Validasi waktu (Logika Tanggal)
-- Mencari data error di mana tanggal sampai LEBIH DULU daripada tanggal beli.
SELECT order_id, order_purchase_timestamp, order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 3. Cek Format Lokasi (Geolocation)
-- Memastikan tidak ada koordinat yang null di tabel customer (Sample check)
SELECT count(*) as jumlah_missing_zip
FROM olist_customers_dataset
WHERE customer_zip_code_prefix IS NULL;

-- 4. Harga & Ongkir tidak boleh ada yang negatif
SELECT *
FROM olist_ecommerce.olist_order_items_dataset
WHERE price < 0 OR freight_value < 0;

-- 5. Cek Kategori Produk yang Tidak Ada Terjemahannya
-- karena nama kategori akan ditampilkan dalam bahasa inggris di tableau
SELECT p.product_category_name, COUNT(*) as jumlah_produk
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL
  AND p.product_category_name IS NOT NULL -- Abaikan jika memang datanya kosong
GROUP BY p.product_category_name
ORDER BY jumlah_produk DESC;

-- PATCHING: MENAMBAL TERJEMAHAN YANG HILANG
-- 1. Masukkan terjemahan untuk 'portateis_cozinha'
INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portable_food_preparers');

-- 2. Masukkan terjemahan untuk 'pc_gamer'
INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer');

-- Verifikasi apakah sudah masuk
SELECT * FROM product_category_name_translation 
WHERE product_category_name IN ('portateis_cozinha_e_preparadores_de_alimentos', 'pc_gamer');


--  CREATING MASTER VIEW (TRANSFORMASI)
-- View ini menggabungkan 5 tabel inti menjadi satu tabel denormalisasi (Wide Table)
-- Tujuannya Agar nantinya Tableau tidak perlu melakukan 5x JOIN yang berat.

CREATE VIEW olist_analytics_master AS
SELECT 
    -- [DIMENSI ORDER]
    o.order_id,
    oi.order_item_id,
    o.customer_id,
    oi.seller_id,
    oi.product_id,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') as order_month_year,
    -- Menghitung durasi pengiriman aktual (dalam hari)
    EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) as actual_shipping_days,
    -- Menghitung selisih estimasi vs aktual (Positif = Lebih cepat, Negatif = Telat)
    EXTRACT(DAY FROM (o.order_estimated_delivery_date - o.order_delivered_customer_date)) as delivery_accuracy_days,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Unknown') as product_category_name,
    p.product_weight_g,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) as total_order_value,
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On Time'
        ELSE 'In Progress/Canceled'
    END as delivery_status
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
LEFT JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
LEFT JOIN olist_products_dataset p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name;


