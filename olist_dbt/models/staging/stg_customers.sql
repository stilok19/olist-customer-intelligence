SELECT DISTINCT
  customer_unique_id,
  customer_id,
  customer_city,
  customer_state,
  customer_zip_code_prefix AS zip_code
FROM {{ source('olist_raw', 'raw_customers') }}
WHERE customer_unique_id IS NOT NULL