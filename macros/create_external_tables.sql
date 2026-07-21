{% macro create_external_tables() %}

{% set folders = [
    'customer_data',
    'product_data',
    'supplier_data',
    'employee_data',
    'orders_data',
    'campaign_data',
    'store_data'
] %}


{% for folder in folders %}

    {% set table_name = folder | replace('_data','') | upper ~ '_EXT' %}

    {% set sql %}

    CREATE OR REPLACE EXTERNAL TABLE
    CT_SALONI_DIXIT_DB.CAPSTONE_23619.{{ table_name }}
    (
        RAW_DATA VARIANT AS (VALUE)
    )
    LOCATION=@CT_SALONI_DIXIT_DB.CAPSTONE_23619.RAW_DATA/Capstone_Project_Data/{{ folder }}
    FILE_FORMAT=(
        TYPE=JSON
        STRIP_OUTER_ARRAY=TRUE
    )
    AUTO_REFRESH=FALSE;

    {% endset %}

    {{ log("Creating external table: " ~ table_name, info=True) }}
    {{ run_query(sql) }}

{% endfor %}

{% endmacro %}