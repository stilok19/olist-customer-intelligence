# Olist Customer Intelligence Dashboard

## Live Dashboard
[View Dashboard](https://datastudio.google.com/reporting/2fb90688-5268-4d7f-bffa-ec14a3ce7e86)

## Pages
1. **Executive Overview** — KPIs, revenue by state, order status
2. **Customer Segments** — RFM analysis, K-Means clusters
3. **Revenue Trends** — Monthly revenue, top categories, geo map
4. **Churn Risk Monitor** — Risk tiers, at-risk customers, segment churn

## Data Sources
All data sourced from BigQuery `olist_analytics` dataset:
- mart_customer_orders
- mart_rfm  
- mart_revenue
- ml_churn_scores