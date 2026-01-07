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
```
## Hasil Analisis:
<img width="1301" height="323" alt="image" src="https://github.com/user-attachments/assets/711ea941-e3d8-499e-80ad-0619161980a2" />

**Actionable Insight:**
Dengan mengurutkan berdasarkan tingkat keterlambatan tertinggi, Negara bagian "AL" memiliki tingkat keterlambatan tertinggi.

**Rekomendasi:** Perlu dilakukan audit vendor logistik di wilayah tersebut atau penyesuaian estimasi waktu kirim (ETA) di aplikasi agar ekspektasi pelanggan lebih realistis.

### 2. Analisis Perilaku Pembayaran Pelanggan
**Business Problem:** Tim Finance membutuhkan profil likuiditas pembayaran untuk menentukan strategi cash flow dan kemitraan bank.

**SQL Approach:** Menggunakan Window Function SUM() OVER() untuk menghitung kontribusi persentase setiap metode pembayaran terhadap total revenue secara efisien.

```sql
-- Mengidentifikasi tipe pembayaran yang paling banyak digunakan dan kontribusinya terhadap revenue
SUM(p.payment_value) as total_payment_value,
    ROUND(SUM(p.payment_value) * 100.0 / SUM(SUM(p.payment_value)) OVER(), 2) as percentage_of_revenue
```
## Hasil Analisis:
<img width="1312" height="248" alt="image" src="https://github.com/user-attachments/assets/30469890-9d68-44e2-8ef9-4a61f25728c3" />

**Actionable Insight:**
Kartu Kredit mendominasi 78,34% transaksi, diikuti oleh Boleto dengan 17,92%

**Rekomendasi:** Fokuskan promo cicilan 0% dengan bank partner utama untuk meningkatkan Basket Size.

### 3. Strategi Pertumbuhan: Analisis Pareto (80/20)
**Business Problem:** Tim Marketing memiliki budget terbatas. Produk kategori apa yang harus diprioritaskan untuk kampanye iklan agar ROI maksimal?

**SQL Approach:** Menerapkan Prinsip Pareto menggunakan RANK() dan Running Total untuk mengidentifikasi kategori produk "Sapi Perah" (Cash Cow).

```sql
-- Cuplikan Logika Ranking
RANK() OVER(ORDER BY revenue DESC) as rank_position,
SUM(revenue) OVER(ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
```
## Hasil Analisis:
<img width="1311" height="308" alt="image" src="https://github.com/user-attachments/assets/cfb8cb1b-ba9f-4e8e-ae4d-0b686eb2d234" />

**Insight:**
Hasil diatas merupakan kategori teratas yang menyumbang mayoritas pendapatan perusahaan.

**Rekomendasi:** 
Alokasikan 80% budget marketing hanya untuk kategori-kategori ini untuk efisiensi biaya iklan.

### 4. Strategi Retensi Pelanggan (RFM Segmentation)
**Business Problem:** Pendekatan pemasaran "satu pesan untuk semua" tidak efisien dan membuang budget. Tim Marketing perlu mengelompokkan pelanggan untuk memberikan perlakuan yang personal, seperti mencegah pelanggan VIP agar tidak pindah ke kompetitor (*Churn Prevention*).

**SQL Approach:**
Saya membangun model segmentasi **RFM (Recency, Frequency, Monetary)** menggunakan SQL.
* **Teknik:** Menggunakan `MAX() OVER()` untuk menentukan "Tanggal Hari Ini" secara dinamis berdasarkan data terakhir di dataset, sehingga analisis tetap valid kapanpun dijalankan.
* **Logika Bisnis:** Menggunakan `CASE WHEN` bertingkat untuk memberi label pelanggan (VIP, Active, Churned).

```sql
-- Cuplikan Logika Segmentasi (Business Rules)
CASE 
    WHEN recency_days <= 90 AND total_spent > 500 THEN 'VIP / Champion'
    WHEN recency_days BETWEEN 91 AND 270 AND total_spent > 500 THEN 'Loyal - Need Attention'
    WHEN recency_days > 270 THEN 'Churned / Inactive'
    ELSE 'Others'
END as customer_segment
```
## Hasil Analisis:
<img width="1311" height="292" alt="image" src="https://github.com/user-attachments/assets/4150627e-8bae-43ce-ada5-b7e196945a1d" />

**Insight:**
Teridentifikasi segmen 'Loyal - Need Attention' (Pelanggan kaya yang sudah agak lama tidak belanja).

**Rekomendasi:** 
Segera kirimkan Voucher atau penawaran eksklusif kepada kelompok ini untuk mencegah mereka menjadi Churned.
Untuk segmen 'VIP / Champion', berikan akses early-bird ke produk baru untuk menjaga loyalitas.

















