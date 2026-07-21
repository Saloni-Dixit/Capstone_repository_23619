SELECT
    RAW_DATA AS JSON_DATA,
    METADATA$FILENAME AS SOURCE_FILE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP

FROM {{ source('raw_data', 'SUPPLIER_EXT') }}

{% if is_incremental() %}
where SOURCE_FILE not in (
    select distinct SOURCE_FILE
    from {{ this }}
)
{% endif %}