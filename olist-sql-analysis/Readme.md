# 🇧🇷 Olist E-Commerce Analysis: Supply Chain & Revenue Optimization

<img width="1800" height="378" alt="dataset-cover" src="https://github.com/user-attachments/assets/9eb9e6f6-2d03-4680-ad89-84dccfc4352c" />


## 📌 Executive Summary
**Project Role:** Data Analyst  
**Business Context:** Olist adalah platform E-Commerce terbesar di Brasil yang menghubungkan penjual kecil dengan pelanggan di seluruh negeri.  
**Objective:** Mengidentifikasi inefisiensi logistik (pengiriman), peluang peningkatan pendapatan, dan segmentasi pelanggan menggunakan analisis data relasional.  
**Result:** Mengungkap akar masalah keterlambatan pengiriman di negara bagian tertentu dan mengidentifikasi Top 20% kategori produk yang menyumbang mayoritas pendapatan (Pareto Principle).

---

## 🛠️ Tech Stack & Methodology
* **SQL (PostgreSQL):** Pembersihan data, pemodelan data (*Data Modeling*), dan analisis bisnis kompleks menggunakan *CTEs, Window Functions,* dan *Multi-table Joins*.
* **DBeaver:** Database management dan query execution.
* **Tableau:** Visualisasi data interaktif dan dashboarding.

---

## 🔍 Key Analysis & Business Insights

Berikut adalah sorotan analisis utama yang dilakukan untuk menjawab pertanyaan strategis bisnis.

### 1. Evaluasi Performa Logistik Regional
**Business Problem:** Negara kepulauan atau wilayah luas seringkali memiliki tantangan logistik. Manajemen ingin mengetahui wilayah mana yang memiliki performa pengiriman terburuk yang berpotensi meningkatkan *Churn Rate*.

**SQL Approach:**
Saya melakukan *3-Table Joins* (Orders, Items, Customers) dan membangun metrik kustom `late_delivery_rate` untuk mengukur persentase pesanan yang melanggar estimasi waktu kirim (SLA).

```sql
-- Cuplikan Logika Perhitungan Keterlambatan
ROUND(
    (SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)::DECIMAL / 
    COUNT(o.order_id)) * 100
, 2) as late_delivery_rate
