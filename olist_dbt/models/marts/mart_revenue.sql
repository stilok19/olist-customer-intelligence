SELECT
  DATE_TRUNC(DATE(o.purchased_at), MONTH) AS month,
  p.product_category,
  c.customer_state,
  COUNT(DISTINCT o.order_id)              AS total_orders,
  COUNT(DISTINCT c.customer_unique_id)    AS unique_customers,
  SUM(i.total_value)                      AS total_revenue,
  AVG(i.total_value)                      AS avg_order_value,
  SUM(i.freight_value)                    AS total_freight,
  AVG(o.delivery_days)                    AS avg_delivery_days
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_order_items') }} i
  ON o.order_id = i.order_id
LEFT JOIN {{ ref('stg_products') }} p
  ON i.product_id = p.product_id
LEFT JOIN {{ ref('stg_customers') }} c
  ON o.customer_id = c.customer_id
WHERE
  o.order_status = 'delivered'
  AND o.purchased_at IS NOT NULL
GROUP BY
  DATE_TRUNC(DATE(o.purchased_at), MONTH),
  p.product_category,
  c.customer_state