SELECT
    d.year,
    d.month,
    s.region,
    SUM(f.total_sales_amount) AS total_sales,
    SUM(f.profit_amount) AS total_profit

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_date') }} d
    ON f.date_key = d.date_key

JOIN {{ ref('dim_store') }} s
    ON f.store_key = s.store_key

GROUP BY
    d.year,
    d.month,
    s.region

ORDER BY
    d.year,
    d.month