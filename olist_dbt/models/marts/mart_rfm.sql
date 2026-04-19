WITH rfm_scores AS (
  SELECT
    customer_unique_id,
    customer_city,
    customer_state,
    days_since_last_order                               AS recency,
    total_orders                                        AS frequency,
    total_spent                                         AS monetary,
    NTILE(5) OVER (ORDER BY days_since_last_order DESC) AS r_score,
    NTILE(5) OVER (ORDER BY total_orders ASC)           AS f_score,
    NTILE(5) OVER (ORDER BY total_spent ASC)            AS m_score
  FROM {{ ref('mart_customer_orders') }}
  WHERE total_orders > 0
),
rfm_combined AS (
  SELECT
    *,
    ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_score
  FROM rfm_scores
)
SELECT
  *,
  CASE
    WHEN rfm_score >= 4.5                  THEN 'Champion'
    WHEN rfm_score >= 4.0 AND f_score >= 4 THEN 'Loyal'
    WHEN rfm_score >= 3.5 AND r_score >= 4 THEN 'Recent'
    WHEN rfm_score >= 3.0                  THEN 'Promising'
    WHEN r_score <= 2 AND f_score >= 3     THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2     THEN 'Lost'
    ELSE                                        'Needs Attention'
  END AS customer_segment
FROM rfm_combined