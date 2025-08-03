-- TABLE ANALISIS KERJA BISNIS KIMIA FARMA TAHUN 2020-2023 
-- Dibuat oleh: Arvi Hasanah 

-- Membuat tabel analisis kerja bisnis dari data source
CREATE TABLE `rakamin-kf-analytics-467616.Kimia_Farma.Tabel_Analisis_Kerja_kf` AS  

-- Definisi CTE (Common Table Expressions)
WITH 

-- CTE transaksi
transaksi AS ( 
  SELECT
    transaction_id, 
    date, 
    branch_id, 
    customer_name, 
    product_id, 
    price AS actual_price, 
    discount_percentage, 
    rating AS rating_transaction, 
    CASE 
      WHEN price <= 50000 THEN 10 
      WHEN price > 50000 AND price <= 100000 THEN 15
      WHEN price > 100000 AND price <= 200000 THEN 20 
      WHEN price > 200000 AND price <= 300000 THEN 25 
      WHEN price > 300000 THEN 30 
    END AS percentage_gross_laba, 
    price * (1 - discount_percentage) AS nett_sales
  FROM `Kimia_Farma.kf_final_transaction`
),

-- CTE inventory
inventory AS (
  SELECT 
    inventory_ID, 
    branch_id,
    product_id, 
    product_name, 
    opname_stock AS stock
  FROM `Kimia_Farma.kf_inventory`
), 

-- CTE cabang
cabang AS (
  SELECT 
    branch_id,
    branch_name,
    kota AS city,
    provinsi AS province,
    rating AS rating_branch
  FROM `Kimia_Farma.kf_kantor_cabang`
),

-- CTE product
product AS (
  SELECT
    product_id, 
    product_name, 
    product_category, 
    price AS actual_price
  FROM `Kimia_Farma.kf_product`
)

-- Query utama: menggabungkan seluruh CTE
SELECT 
  transaksi.transaction_id, 
  transaksi.date, 
  transaksi.customer_name, 
  product.product_id, 
  product.product_name, 
  product.product_category, 
  transaksi.actual_price, 
  transaksi.discount_percentage, 
  transaksi.percentage_gross_laba,
  transaksi.nett_sales,
  -- Perhitungan laba bersih
  transaksi.nett_sales * (transaksi.percentage_gross_laba / 100) AS nett_profit, 
  cabang.branch_id, 
  cabang.branch_name, 
  cabang.city, 
  cabang.province, 
  inventory.inventory_ID, 
  inventory.stock,
  cabang.rating_branch,
  transaksi.rating_transaction

FROM transaksi 
JOIN product ON transaksi.product_id = product.product_id
JOIN inventory ON transaksi.product_id = inventory.product_id 
              AND transaksi.branch_id = inventory.branch_id
JOIN cabang ON transaksi.branch_id = cabang.branch_id

-- Mengurutkan hasil berdasarkan tanggal transaksi 
ORDER BY transaksi.date;
