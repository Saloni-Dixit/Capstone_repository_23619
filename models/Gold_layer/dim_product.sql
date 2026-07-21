{{ config(materialized='table') }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
    product_id,
    product_name,
    category,
    subcategory,
    product_line,
    brand,
    supplier_id,
    cost_price,
    unit_price,
    profit_margin_percentage,
    stock_quantity,
    reorder_level,
    low_stock_flag,
    is_featured,
    launch_date,
    last_modified_date
FROM {{ ref('silver_product') }}