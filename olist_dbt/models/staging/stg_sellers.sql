SELECT
  seller_id,
  seller_city,
  seller_state,
  seller_zip_code_prefix AS zip_code
FROM {{ source('olist_raw', 'raw_sellers') }}
WHERE seller_id IS NOT NULL