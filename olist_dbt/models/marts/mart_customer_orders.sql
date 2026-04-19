SELECT
  c.customer_unique_id,
  c.customer_city,
  c.customer_state,
  COUNT(DISTINCT o.order_id)            AS total_orders,
  SUM(i.total_value)                    AS total_spent,
  AVG(i.total_value)                    AS avg_order_value,
  MIN(DATE(o.purchased_at))             AS first_order_date,
  MAX(DATE(o.purchased_at))             AS last_order_date,
  DATE_DIFF(
    MAX(DATE(o.purchased_at)),
    MIN(DATE(o.purchased_at)),
    DAY
  )                                     AS customer_lifespan_days,
  DATE_DIFF(
    DATE('2018-10-17'),
    MAX(DATE(o.purchased_at)),
    DAY
  )                                     AS days_since_last_order,
  COUNTIF(o.order_status = 'delivered') AS delivered_orders,
  COUNTIF(o.order_status = 'cancelled') AS cancelled_orders
FROM {{ ref('stg_customers') }} c
LEFT JOIN {{ ref('stg_orders') }} o
  ON c.customer_id = o.customer_id
LEFT JOIN {{ ref('stg_order_items') }} i
  ON o.order_id = i.order_id
GROUP BY
  c.customer_unique_id,
  c.customer_city,
  c.customer_state