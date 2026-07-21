WITH product_flattened AS (
    SELECT
        f.value:product_id::STRING AS product_id,
        f.value:name::STRING AS product_name,
        f.value:short_description::STRING AS short_description,
        f.value:technical_specs::STRING AS technical_specs,
        f.value:category::STRING AS category,
        f.value:subcategory::STRING AS subcategory,
        f.value:product_line::STRING AS product_line,
        f.value:brand::STRING AS brand,
        f.value:color::STRING AS color,
        f.value:size::STRING AS size,
        f.value:dimensions::STRING AS dimensions,
        f.value:weight::STRING AS weight,
        f.value:warranty_period::STRING AS warranty_period,
        f.value:supplier_id::STRING AS supplier_id,
        f.value:unit_price::NUMBER(18,2) AS unit_price,
        f.value:cost_price::NUMBER(18,2) AS cost_price,
        f.value:stock_quantity::NUMBER AS stock_quantity,
        f.value:reorder_level::NUMBER AS reorder_level,
        f.value:is_featured::BOOLEAN AS is_featured,
        f.value:launch_date::STRING AS launch_date,
        f.value:last_modified_date::STRING AS last_modified_date,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM {{ ref('product') }},
    LATERAL FLATTEN(input => JSON_DATA:products_data) f
),
product_transformed AS (
    SELECT
        TRIM(product_id) AS product_id,
        INITCAP(REGEXP_REPLACE(TRIM(product_name),'[^A-Za-z0-9 ]','')) AS product_name,
        TRIM(short_description) AS short_description,
        TRIM(technical_specs) AS technical_specs,

        CONCAT(INITCAP(REGEXP_REPLACE(TRIM(product_name),'[^A-Za-z0-9 ]',''))
        ,' | ',TRIM(short_description),
        ' | ',TRIM(technical_specs)) AS product_full_description,
        
        INITCAP(TRIM(category)) AS category,
        INITCAP(TRIM(subcategory)) AS subcategory,
        INITCAP(TRIM(product_line)) AS product_line,

        CONCAT(INITCAP(TRIM(category)),' > ',
        INITCAP(TRIM(subcategory)),' > ',
        INITCAP(TRIM(product_line))) AS product_hierarchy,

        INITCAP(TRIM(brand)) AS brand,
        INITCAP(TRIM(color)) AS color,
        INITCAP(TRIM(size)) AS size,
        TRIM(dimensions) AS dimensions,
        TRIM(weight) AS weight,
        INITCAP(TRIM(warranty_period)) AS warranty_period,
        TRIM(supplier_id) AS supplier_id,
        COALESCE(unit_price,0) AS unit_price,
        COALESCE(cost_price,0) AS cost_price,
        CASE
            WHEN unit_price>0 THEN ((unit_price-cost_price)/unit_price)*100
            ELSE NULL
        END AS profit_margin_percentage,
        COALESCE(stock_quantity,0) AS stock_quantity,
        COALESCE(reorder_level,0) AS reorder_level,
        CASE
            WHEN stock_quantity<reorder_level THEN TRUE
            ELSE FALSE
        END AS low_stock_flag,
        COALESCE(is_featured,FALSE) AS is_featured,
        TRY_TO_DATE(launch_date) AS launch_date,
        TRY_TO_DATE(last_modified_date) AS last_modified_date,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM product_flattened
)
SELECT *
FROM product_transformed
QUALIFY ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY last_modified_date DESC)=1