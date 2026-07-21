SELECT
    c.customer_key,
    c.full_name,
    c.customer_segment,

    COUNT(DISTINCT f.order_id) AS total_orders,

    SUM(f.total_sales_amount) AS total_spend,

    AVG(f.total_sales_amount) AS average_order_value,

    MAX(d.full_date) AS last_purchase_date

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_customers') }} c
    ON f.customer_key = c.customer_key

JOIN {{ ref('dim_date') }} d
    ON f.date_key = d.date_key

GROUP BY
    c.customer_key,
    c.full_name,
    c.customer_segment