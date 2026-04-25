# 🛒 Olist Customer Intelligence Platform

> I built an end-to-end customer intelligence platform to understand why 97% of customers never return — and what we can do about it.
## Data Disclaimer

The Olist dataset assigns a **new `customer_id` for every order**, 
even when the same person places multiple orders. This means the 
dataset does not perfectly reflect real-world repeat purchase behavior.

However, using `customer_unique_id` as the true customer identifier, 
this project simulates a realistic business scenario where:

- The company successfully acquires new customers
- But struggles to retain them for a second purchase

**This project is intentionally framed as if Olist were operating 
with a genuine retention problem** — using the data as a proxy to 
demonstrate how a data scientist would diagnose, analyze, and build 
solutions for a real-world customer churn challenge.

All analytical decisions, model designs, and business recommendations 
should be interpreted within this context. 

[![BigQuery](https://img.shields.io/badge/BigQuery-Data%20Warehouse-4285F4?logo=google-cloud)](https://cloud.google.com/bigquery)
[![dbt](https://img.shields.io/badge/dbt-Data%20Transforms-FF694B?logo=dbt)](https://www.getdbt.com/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)](https://python.org)
[![LightGBM](https://img.shields.io/badge/LightGBM-ML%20Model-2ecc71)](https://lightgbm.readthedocs.io/)
[![Data(Looker) Studio](https://img.shields.io/badge/Looker%20Studio-Dashboard-4285F4?logo=google)](https://lookerstudio.google.com)

---

## Table of Contents
- [Business Problem](#business-problem)
- [Key Findings](#key-findings)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Pipeline](#data-pipeline)
- [Machine Learning](#machine-learning)
- [Dashboard](#dashboard)
- [How to Run](#how-to-run)
- [Business Recommendations](#business-recommendations)

---

## Business Problem

Olist is Brazil's largest online marketplace connecting small retailers to customers across the country. Despite strong customer acquisition, **the platform faces a critical retention crisis**:

```
96,096 unique customers
99,441 total orders
─────────────────────────────────────
Average orders per customer:  1.03
Single-order customers:       97%
```

**Nearly every customer orders once and never comes back.**

This project answers three critical business questions:

| Question | Approach |
|----------|----------|
| Who are our customers and how do they behave? | RFM Segmentation + K-Means Clustering |
| Which customers are about to churn? | LightGBM Churn Prediction |
| Where should marketing focus its budget? | Segment-specific risk scoring |

---

## Key Findings

### Finding 1 — The Leaky Bucket Problem
```
New customers arrive → order once → never return
     ↓
Cluster 0 (Recent One-Timers)  →  ignored  →  become Lost Customers
```
Olist is acquiring customers successfully but losing them immediately after the first order. The platform needs to shift investment from acquisition to retention.

### Finding 2 — Revenue Is Dangerously Concentrated
```
2.6% of customers (High Value Whales)  →  18% of total revenue
3.0% of customers (Repeat Buyers)      →   5% of total revenue
─────────────────────────────────────────────────────────────
5.6% of customers generate 23% of revenue

Losing ONE High Value Whale = losing R$1,173 in revenue
Losing ONE typical customer = losing R$135 in revenue
```
Protecting the top 5.6% of customers is the single highest-ROI retention action.

### Finding 3 — Four Distinct Customer Segments

| Cluster | Label | Customers | Avg Spend | Action |
|---------|-------|-----------|-----------|--------|
| 0 | Recent One-Timers | 51,890 (54%) | R$135 | Re-engagement campaign |
| 1 | Lost Customers | 38,339 (40%) | R$134 | Win-back discount |
| 2 | Repeat Buyers | 2,845 (3%) | R$286 | Loyalty program |
| 3 | High Value Whales | 2,465 (2.6%) | R$1,173 | VIP treatment |

### Finding 4 — Delivery Experience Drives Churn 
LightGBM feature importance reveals:
```
Top churn predictors:
  1. avg_freight_value       ← high shipping cost = churn
  2. customer_lifespan_days  ← longer relationship = retained
  3. avg_delivery_days       ← slow delivery = churn
```

### Finding 5 — Churn Threshold Design Decision 
```
Attempted: Dynamic per-customer purchase cycle threshold
Problem:   97% of customers have only 1 order — no cycle to calculate
Solution:  90-day churn threshold (e-commerce industry standard)

Sensitivity analysis:
  60 days  → 98.3% churn  too aggressive
  90 days  → 90.1% churn  ← chosen (industry standard)
  180 days → 71.0% churn  too lenient
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                             │
│                                                                 │
│   Kaggle — Olist Brazilian E-Commerce Dataset                   │
│   100K orders · 96K customers · 9 CSV files                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Python upload script
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DATA LAKE (GCS)                             │
│                                                                 │
│   gs://olist-raw-data-stilok19/                                 │
│   └── raw/                                                      │
│       ├── olist_orders_dataset.csv                              │
│       ├── olist_customers_dataset.csv                           │
│       ├── olist_order_items_dataset.csv                         │
│       ├── olist_order_payments_dataset.csv                      │
│       ├── olist_order_reviews_dataset.csv                       │
│       ├── olist_products_dataset.csv                            │
│       ├── olist_sellers_dataset.csv                             │
│       └── product_category_name_translation.csv                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │ LOAD DATA INTO (BigQuery)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  DATA WAREHOUSE (BigQuery)                      │
│                                                                 │
│  RAW LAYER              STAGING LAYER (dbt)                     │
│  ─────────────          ────────────────────                    │
│  raw_orders        →    stg_orders                              │
│  raw_customers     →    stg_customers                           │
│  raw_order_items   →    stg_order_items                         │
│  raw_order_payments →   stg_order_payments                      │
│  raw_order_reviews →    stg_order_reviews                       │
│  raw_products      →    stg_products                            │
│  raw_sellers       →    stg_sellers                             │
│                                                                 │
│  MART LAYER (dbt)                                               │
│  ────────────────────────────────                               │
│  mart_customer_orders   (customer KPIs)                         │
│  mart_rfm               (RFM scores + segments)                 │
│  mart_revenue           (revenue by month/category/state)       │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Python + LightGBM
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ML LAYER (VS Code + Jupyter)                  │
│                                                                 │
│  notebooks/                                                     │
│  ├── 01_eda.ipynb              EDA + business insights          │
│  ├── 02_rfm_segmentation.ipynb RFM + K-Means (k=4)             │
│  └── 03_churn_prediction.ipynb LightGBM churn model            │
│                                                                 │
│  ML OUTPUT TABLES (BigQuery)                                    │
│  ├── ml_kmeans_segments        K-Means cluster per customer     │
│  └── ml_churn_scores           Churn probability + risk tier    │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Native BigQuery connector
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   DASHBOARD (Looker Studio)                     │
│                                                                 │
│  Page 1: Executive Overview    KPIs + revenue by state          │
│  Page 2: Customer Segments     RFM + K-Means clusters           │
│  Page 3: Revenue Trends        Monthly trend + top categories   │
│  Page 4: Churn Risk Monitor    Risk tiers + at-risk customers   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Tool | Purpose | Cost |
|-------|------|---------|------|
| Data Lake | Google Cloud Storage | Raw CSV storage | Free (5GB) |
| Data Warehouse | BigQuery | SQL transforms + ML output | Free (1TB/mo) |
| Data Transforms | dbt Core | Staging + mart models | Free |
| ML Development | VS Code + Jupyter | EDA + modeling | Free |
| ML Models | LightGBM + Scikit-learn | Churn + segmentation | Free |
| Dashboard | Looker Studio | Business reporting | Free |
| Version Control | GitHub | All code + SQL | Free |
| **Total Cost** | | | **$0** |

---

## Project Structure

```
olist-customer-intelligence/
├── README.md
├── ingestion/
│   └── upload_to_gcs.py           ← uploads CSVs to GCS
├── olist_dbt/
│   ├── dbt_project.yml
│   └── models/
│       ├── staging/
│       │   ├── sources.yml        ← raw table definitions
│       │   ├── stg_orders.sql
│       │   ├── stg_customers.sql
│       │   ├── stg_order_items.sql
│       │   ├── stg_order_payments.sql
│       │   ├── stg_order_reviews.sql
│       │   ├── stg_products.sql
│       │   └── stg_sellers.sql
│       └── marts/
│           ├── mart_customer_orders.sql
│           ├── mart_rfm.sql
│           └── mart_revenue.sql
├── notebooks/
│   ├── 01_eda.ipynb               ← exploratory analysis
│   ├── 02_rfm_segmentation.ipynb  ← K-Means clustering
│   └── 03_churn_prediction.ipynb  ← LightGBM model
└── dashboard/
    └── README.md                  ← dashboard link
```

---

## Data Pipeline

### Ingestion
Raw Olist CSVs are downloaded from Kaggle and uploaded to GCS:
```bash
python ingestion/upload_to_gcs.py
```

### Transformation (dbt)
Three-layer architecture following data warehouse best practices:

```
Raw → Staging → Marts
```

- **Raw:** Direct load from GCS, no transformations
- **Staging:** Clean, type-cast, deduplicate, standardize
- **Marts:** Business-ready aggregations for analytics and ML

Run all transformations:
```bash
cd olist_dbt
dbt run
```

Run specific model:
```bash
dbt run --select mart_rfm
```

---

## Machine Learning

### Notebook 1 — EDA (`01_eda.ipynb`)
- Revenue trend analysiห
- Customer geography (SP dominates at 42% of revenue)
- Product category analysis (top 10 categories)
- Review score distribution

### Notebook 2 — RFM Segmentation (`02_rfm_segmentation.ipynb`)
- Built RFM scores from transaction history
- Applied K-Means clustering (k=4 via elbow method)
- Identified 4 actionable customer segments
- Wrote segment labels back to BigQuery

**Elbow method result:** k=4 optimal
```
k=4 → k=5 inflection point → diminishing returns after 4 clusters
```

### Notebook 3 — Churn Prediction (`03_churn_prediction.ipynb`)

**Feature Selection Methodology:**

Rather than blindly adding features, applied four complementary methods:
1. Pearson correlation — linear relationships
2. Point-biserial correlation — binary target specific
3. Mutual information — captures non-linear patterns
4. LightGBM feature importance — model validation

**Leakage Prevention:**

Carefully removed features to prevent target leakage:
```
days_since_last_order  → directly defines churn label
r_score, f_score, m_score → derived from same raw signals
rfm_score  → average of r/f/m scores
cluster_label → built from same RFM data
```

**Active Window Approach:**
```
Problem:  Right-censoring bias — 97% of customers appear
          churned simply because dataset ended Oct 2018
Solution: Apply 90-day churn threshold within window
```

**Final Model:**
```
Algorithm:    LightGBM Classifier
Features:     12 behavioral signals (no leakage)
Train AUC:    0.9684
Test AUC:     0.9685
Gap:          0.0001  ← no overfitting
```

**Future Plan - Segment-Specific Modeling:**

Trained separate models per K-Means cluster because:
- Each segment has different churn drivers
- Different business interventions needed per segment
- Avoids dominant segment biasing the global model
- More actionable predictions per business team

---

## Dashboard

**[View Live Dashboard](https://datastudio.google.com/reporting/2fb90688-5268-4d7f-bffa-ec14a3ce7e86)**

| Page | Description | Key Metrics |
|------|-------------|-------------|
| Executive Overview | Top-level KPIs | Revenue, customers, avg order value |
| Customer Segments | RFM + K-Means | Segment distribution, revenue per segment |
| Revenue Trends | Time series | Monthly growth, top categories, geo map |
| Churn Risk Monitor | ML outputs | Risk tiers, at-risk customers, revenue at risk |

---

## How to Run

### Prerequisites
```bash
# Install dependencies
pip install dbt-bigquery lightgbm google-cloud-bigquery \
            pandas numpy matplotlib seaborn scikit-learn

# Authenticate with GCP
gcloud auth application-default login
gcloud config set project olist-analytics-XXXXXX
```

### 1. Download Data
```bash
kaggle datasets download -d olistbr/brazilian-ecommerce --unzip -p data/
```

### 2. Upload to GCS
```bash
python ingestion/upload_to_gcs.py
```

### 3. Load Raw Tables
Run `LOAD DATA INTO` statements in BigQuery console.

### 4. Run dbt Transforms
```bash
cd olist_dbt
dbt run
```

### 5. Run ML Notebooks
Open in VS Code:
```
notebooks/01_eda.ipynb
notebooks/02_rfm_segmentation.ipynb
notebooks/03_churn_prediction.ipynb
```

---

## Business Recommendations

Based on the analysis, Olist should prioritize:

### Immediate Actions (0-30 days)
1. **Launch win-back campaign** for Cluster 0 (Recent One-Timers) — 51,890 customers still reachable before they become permanently lost
2. **Create VIP program** for Cluster 3 (High Value Whales) — protect R$2.9M in at-risk revenue
3. **Investigate freight costs** — #1 churn predictor, directly controllable by operations team

### Short Term (30-90 days)
1. **Implement loyalty rewards** for Cluster 2 (Repeat Buyers) — only 3% of base but proven they return
2. **Improve delivery speed** — avg_delivery_days is top 3 churn predictor
3. **Deploy churn model scores** to CRM for automated email triggers by risk tier

### Long Term (90+ days)
1. Build real-time churn scoring pipeline
2. Add clickstream/browsing data for richer behavioral features
3. Implement dynamic churn thresholds as repeat purchase data grows
4. A/B test retention interventions per segment

---

## Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

```
Orders:      99,441
Customers:   96,096 unique
Time period: Sep 2016 — Oct 2018
Geography:   Brazil (26 states)
Categories:  73 product categories
```

---

## Author

**May Tilokruangchai**
PhD, Information Systems — University of Massachusetts Boston

[![LinkedIn](https://img.shields.io/badge/LinkedIn-stilok19-0077B5?logo=linkedin)](https://LinkedIn.com/in/stilok)
[![GitHub](https://img.shields.io/badge/GitHub-stilok19-181717?logo=github)](https://github.com/stilok19)

---

*Built as a portfolio project demonstrating end-to-end data science skills:*
*data engineering · SQL · dbt · Python · machine learning · business analytics*
