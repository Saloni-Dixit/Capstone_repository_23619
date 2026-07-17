{% macro create_external_tables() %}

{% set folders = [
    'customer',
    'product',
    'supplier',
    'employee',
    'orders',
    'campaign',
    'store'
] %}


{% for folder in folders %}
    {% set table_name = folder | upper ~ '_EXT' %}
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