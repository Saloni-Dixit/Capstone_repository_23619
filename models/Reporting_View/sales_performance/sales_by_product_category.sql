SELECT
    p.category,
    SUM(f.total_sales_amount) AS total_sales,
    SUM(f.profit_amount) AS total_profit,
    SUM(f.quantity_sold) AS total_units_sold

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
    ON f.product_key = p.product_key

GROUP BY
    p.category

ORDER BY
    total_sales DESC