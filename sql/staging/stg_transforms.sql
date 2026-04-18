-- ============================================
-- Staging Layer: Clean and standardize raw tables
-- Run each statement separately in BigQuery
-- ============================================

-- 1. Staging orders
CREATE OR REPLACE TABLE `olist_analytics.stg_orders` AS
SELECT
  order_id,
  customer_id,
  order_status,
  TIMESTAMP(order_purchase_timestamp)      AS purchased_at,
  TIMESTAMP(order_approved_at)             AS approved_at,
  TIMESTAMP(order_delivered_carrier_date)  AS shipped_at,
  TIMESTAMP(order_delivered_customer_date) AS delivered_at,
  TIMESTAMP(order_estimated_delivery_date) AS estimated_delivery_at,
  DATE_DIFF(
    DATE(order_delivered_customer_date),
    DATE(order_purchase_timestamp),
    DAY
  ) AS delivery_days
FROM `olist_analytics.raw_orders`
WHERE order_id IS NOT NULL;

-- 2. Staging customers
CREATE OR REPLACE TABLE `olist_analytics.stg_customers` AS
SELECT DISTINCT
  customer_unique_id,
  customer_id,
  customer_city,
  customer_state,
  customer_zip_code_prefix AS zip_code
FROM `olist_analytics.raw_customers`
WHERE customer_unique_id IS NOT NULL;

-- 3. Staging order items
CREATE OR REPLACE TABLE `olist_analytics.stg_order_items` AS
SELECT
  order_id,
  order_item_id,
  product_id,
  seller_id,
  CAST(price AS FLOAT64)         AS price,
  CAST(freight_value AS FLOAT64) AS freight_value,
  CAST(price AS FLOAT64) + CAST(freight_value AS FLOAT64) AS total_value
FROM `olist_analytics.raw_order_items`
WHERE order_id IS NOT NULL;

-- 4. Staging payments
CREATE OR REPLACE TABLE `olist_analytics.stg_order_payments` AS
SELECT
  order_id,
  payment_type,
  CAST(payment_installments AS INT64) AS payment_installments,
  CAST(payment_value AS FLOAT64)      AS payment_value
FROM `olist_analytics.raw_order_payments`
WHERE order_id IS NOT NULL;

-- 5. Staging reviews
CREATE OR REPLACE TABLE `olist_analytics.stg_order_reviews` AS
SELECT
  review_id,
  order_id,
  CAST(review_score AS INT64) AS review_score,
  review_comment_title,
  review_comment_message,
  CASE
    WHEN CAST(review_score AS INT64) >= 4 THEN 'positive'
    WHEN CAST(review_score AS INT64) = 3  THEN 'neutral'
    ELSE 'negative'
  END AS sentiment_label,
  TIMESTAMP(review_creation_date) AS reviewed_at
FROM `olist_analytics.raw_order_reviews`
WHERE review_id IS NOT NULL;

-- 6. Staging products
CREATE OR REPLACE TABLE `olist_analytics.stg_products` AS
SELECT
  p.product_id,
  COALESCE(t.string_field_1, p.product_category_name) AS product_category,
  CAST(p.product_weight_g AS FLOAT64)  AS weight_g,
  CAST(p.product_length_cm AS FLOAT64) AS length_cm,
  CAST(p.product_height_cm AS FLOAT64) AS height_cm,
  CAST(p.product_width_cm AS FLOAT64)  AS width_cm
FROM `olist_analytics.raw_products` p
LEFT JOIN `olist_analytics.raw_product_category_translation` t
  ON p.product_category_name = t.string_field_0
WHERE p.product_id IS NOT NULL;

-- 7. Staging sellers
CREATE OR REPLACE TABLE `olist_analytics.stg_sellers` AS
SELECT
  seller_id,
  seller_city,
  seller_state,
  seller_zip_code_prefix AS zip_code
FROM `olist_analytics.raw_sellers`
WHERE seller_id IS NOT NULL;