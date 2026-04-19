SELECT
  p.product_id,
  COALESCE(t.string_field_1, p.product_category_name) AS product_category,
  CAST(p.product_weight_g AS FLOAT64)  AS weight_g,
  CAST(p.product_length_cm AS FLOAT64) AS length_cm,
  CAST(p.product_height_cm AS FLOAT64) AS height_cm,
  CAST(p.product_width_cm AS FLOAT64)  AS width_cm
FROM {{ source('olist_raw', 'raw_products') }} p
LEFT JOIN {{ source('olist_raw', 'raw_product_category_translation') }} t
  ON p.product_category_name = t.string_field_0
WHERE p.product_id IS NOT NULL