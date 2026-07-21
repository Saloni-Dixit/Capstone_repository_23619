SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(f.quantity_sold) AS units_sold,
    SUM(f.total_sales_amount) AS total_sales

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
    ON f.product_key = p.product_key

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY
    units_sold DESC

LIMIT 10