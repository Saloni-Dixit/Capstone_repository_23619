SELECT
  e.role,
  COUNT(DISTINCT f.order_id) AS orders,
  SUM(f.total_sales_amount) AS sales,
  SUM(f.profit_amount) AS profit
FROM {{ ref('fact_sales') }} f
JOIN {{ ref('dim_employee') }} e
ON f.employee_key = e.employee_key
GROUP BY e.role
ORDER BY sales DESC