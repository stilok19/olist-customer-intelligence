SELECT
  order_id,
  order_item_id,
  product_id,
  seller_id,
  CAST(price AS FLOAT64)         AS price,
  CAST(freight_value AS FLOAT64) AS freight_value,
  CAST(price + freight_value AS FLOAT64) AS total_value
FROM {{ source('olist_raw', 'raw_order_items') }}
WHERE order_id IS NOT NULL
