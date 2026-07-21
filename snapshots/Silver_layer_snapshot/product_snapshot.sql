{% snapshot product_snapshot %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='product_id',
        strategy='check',
        check_cols=[
            'product_name',
            'short_description',
            'technical_specs',
            'product_full_description',
            'category',
            'subcategory',
            'product_line',
            'product_hierarchy',
            'brand',
            'color',
            'size',
            'dimensions',
            'weight',
            'warranty_period',
            'supplier_id',
            'unit_price',
            'cost_price',
            'stock_quantity',
            'reorder_level',
            'is_featured',
            'launch_date'
        ]
    )
}}

SELECT
    *
FROM {{ ref('silver_product') }}

{% endsnapshot %}