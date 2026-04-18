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

-- (add the rest here)
