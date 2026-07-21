
SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key,
    customer_id,
    full_name,
    customer_age AS age,
    standardized_address AS location,
    income_bracket,
    loyalty_tier,
    customer_segment,
    occupation,
    cleaned_email AS email,
    cleaned_phone AS phone,
    preferred_communication,
    preferred_payment_method,
    marketing_opt_in,
    total_purchases,
    total_spend,
    registration_date,
    last_purchase_date,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE
        WHEN dbt_valid_to IS NULL THEN TRUE
        ELSE FALSE
    END AS is_current
FROM {{ ref('customer_snapshot') }}