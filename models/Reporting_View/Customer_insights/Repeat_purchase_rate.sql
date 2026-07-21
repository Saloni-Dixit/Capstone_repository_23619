WITH customer_orders AS (
SELECT
    customer_key,
    COUNT(DISTINCT order_id) AS orders
FROM {{ ref('fact_sales') }}
GROUP BY customer_key
)
SELECT
COUNT(*) AS total_customers,
SUM(
    CASE
        WHEN orders > 1 THEN 1
        ELSE 0
    END
) AS repeat_customers,
ROUND(SUM(CASE
            WHEN orders > 1 THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),2) AS repeat_purchase_rate_percentage
FROM customer_orders