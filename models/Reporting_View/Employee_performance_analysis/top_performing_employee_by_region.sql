SELECT
  e.full_name,
  s.region,
  SUM(f.total_sales_amount) AS sales,
  SUM(f.profit_amount) AS profit,
  COUNT(DISTINCT f.order_id) AS orders
FROM {{ ref('fact_sales') }} f
JOIN {{ ref('dim_employee') }} e
  ON f.employee_key = e.employee_key
JOIN {{ ref('dim_store') }} s
  ON f.store_key = s.store_key
GROUP BY
  e.full_name,
  s.region
ORDER BY sales DESC