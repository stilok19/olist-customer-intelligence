-- Run each statement separately in BigQuery console

-- Orders
LOAD DATA INTO `olist_analytics.raw_orders`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_orders_dataset.csv'],
  skip_leading_rows = 1
);

-- Customers
LOAD DATA INTO `olist_analytics.raw_customers`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_customers_dataset.csv'],
  skip_leading_rows = 1
);

-- Order items
LOAD DATA INTO `olist_analytics.raw_order_items`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_order_items_dataset.csv'],
  skip_leading_rows = 1
);

-- Order payment
LOAD DATA INTO `olist_analytics.raw_order_payments`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_order_payments_dataset.csv'],
  skip_leading_rows = 1
);

-- Order reviews
LOAD DATA INTO `olist_analytics.raw_order_reviews`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_order_reviews_dataset.csv'],
  skip_leading_rows = 1
);

-- Products
LOAD DATA INTO `olist_analytics.raw_products`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_products_dataset.csv'],
  skip_leading_rows = 1
);

-- Sellers
LOAD DATA INTO `olist_analytics.raw_sellers`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_sellers_dataset.csv'],
  skip_leading_rows = 1
);

-- Geolocation
LOAD DATA INTO `olist_analytics.raw_geolocation`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/olist_geolocation_dataset.csv'],
  skip_leading_rows = 1
);
-- Product category translation
LOAD DATA INTO `olist_analytics.raw_product_category_translation`
FROM FILES (
  format = 'CSV',
  uris = ['gs://olist-raw-data-stilok19/raw/product_category_name_translation.csv'],
  skip_leading_rows = 1
);
