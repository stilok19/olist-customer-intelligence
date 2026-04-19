SELECT
  order_id,
  customer_id,
  order_status,
  TIMESTAMP(order_purchase_timestamp)       AS purchased_at,
  TIMESTAMP(order_approved_at)              AS approved_at,
  TIMESTAMP(order_delivered_carrier_date)   AS shipped_at,
  TIMESTAMP(order_delivered_customer_date)  AS delivered_at,
  TIMESTAMP(order_estimated_delivery_date)  AS estimated_delivery_at,
  DATE_DIFF(
    DATE(order_delivered_customer_date),
    DATE(order_purchase_timestamp),
    DAY
  ) AS delivery_days,
  DATE_DIFF(
    DATE(order_delivered_customer_date),
    DATE(order_estimated_delivery_date), 
    DAY
  ) AS estimate_diff
FROM {{ source('olist_raw', 'raw_orders') }}
WHERE order_id IS NOT NULL