SELECT
  e.employee_key,
  e.full_name,
  e.tenure_years,
  e.performance_rating,
SUM(f.total_sales_amount) AS sales_generated,
  COUNT(DISTINCT f.order_id) AS orders_processed
FROM {{ ref('dim_employee') }} e
LEFT JOIN {{ ref('fact_sales') }} f
  ON e.employee_key = f.employee_key
GROUP BY
  e.employee_key,
  e.full_name,
  e.tenure_years,
  e.performance_rating
ORDER BY sales_generated DESC