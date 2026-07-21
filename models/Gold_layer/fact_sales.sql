SELECT
    {{ dbt_utils.generate_surrogate_key(['s.order_id','s.product_id']) }} AS sales_key,
    s.order_id,
    dc.customer_key,
    dp.product_key,
    ds.store_key,
    de.employee_key,
    dd.date_key,
    s.quantity AS quantity_sold,
    s.unit_price,
    s.quantity * s.unit_price AS total_sales_amount,
    s.quantity * dp.cost_price AS cost_amount,

    CASE
        WHEN s.total_items > 0
        THEN s.discount_amount / s.total_items
        ELSE 0
    END AS discount_amount,

    CASE
        WHEN s.total_items > 0
        THEN s.shipping_cost / s.total_items
        ELSE 0
    END AS shipping_cost,

    s.tax_amount,

    ((s.quantity * s.unit_price)- (s.quantity * dp.cost_price)
        - (
            CASE
                WHEN s.total_items > 0
                THEN s.discount_amount / s.total_items
                ELSE 0
            END
        )
        - (
            CASE
                WHEN s.total_items > 0
                THEN s.shipping_cost / s.total_items
                ELSE 0
            END
        )
    ) AS profit_amount,

    ds.region,

    CASE
        WHEN LOWER(s.order_source) LIKE '%online%'
        THEN 'Online'
        ELSE 'In-Store'
    END AS sales_channel,

    dc.customer_segment AS customer_segment_impact,
    s.order_status,
    s.payment_method,
    s.shipping_method,
    s.processing_days,
    s.shipping_days,
    s.delivery_status,
    s.order_time_of_day,
    s.source_file,
    s.load_timestamp

FROM {{ ref('silver_orders') }} s

LEFT JOIN {{ ref('dim_customers') }} dc
    ON s.customer_id = dc.customer_id
    AND dc.is_current = TRUE

LEFT JOIN {{ ref('dim_product') }} dp
    ON s.product_id = dp.product_id

LEFT JOIN {{ ref('dim_store') }} ds
    ON s.store_id = ds.store_id

LEFT JOIN {{ ref('dim_employee') }} de
    ON s.employee_id = de.employee_id

LEFT JOIN {{ ref('dim_date') }} dd
    ON TO_DATE(s.order_date) = dd.full_date