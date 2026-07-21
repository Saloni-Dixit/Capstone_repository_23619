SELECT
  c.customer_segment,
  COUNT(DISTINCT c.customer_key) AS customers,
  SUM(f.total_sales_amount) AS revenue,
  AVG(f.total_sales_amount) AS avg_purchase_value
FROM {{ ref('fact_sales') }} f
JOIN {{ ref('dim_customers') }} c
ON f.customer_key = c.customer_key
GROUP BY c.customer_segment
ORDER BY revenue DESC