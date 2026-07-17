SELECT
    RAW_DATA AS JSON_DATA,
    METADATA$FILENAME AS SOURCE_FILE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP

FROM {{ source('raw_data', 'SUPPLIER_EXT') }}

{% if is_incremental() %}
where source_file not in (
    select distinct _source_file
    from {{ this }}
)
{% endif %}