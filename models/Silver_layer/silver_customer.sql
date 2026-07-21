WITH customer_flattened AS (
    SELECT
        f.value:customer_id::STRING AS customer_id,
        f.value:first_name::STRING AS first_name,
        f.value:last_name::STRING AS last_name,
        f.value:birth_date::STRING AS birth_date,
        f.value:email::STRING AS email,
        f.value:phone::STRING AS phone,
        f.value:address:street::STRING AS street,
        f.value:address:city::STRING AS city,
        f.value:address:state::STRING AS state,
        f.value:address:country::STRING AS country,
        f.value:address:zip_code::STRING AS zip_code,
        f.value:income_bracket::STRING AS income_bracket,
        f.value:loyalty_tier::STRING AS loyalty_tier,
        f.value:occupation::STRING AS occupation,
        f.value:marketing_opt_in::BOOLEAN AS marketing_opt_in,
        f.value:preferred_communication::STRING AS preferred_communication,
        f.value:preferred_payment_method::STRING AS preferred_payment_method,
        f.value:registration_date::STRING AS registration_date,
        f.value:last_purchase_date::STRING AS last_purchase_date,
        f.value:last_modified_date::STRING AS last_modified_date,
        f.value:total_purchases::NUMBER AS total_purchases,
        f.value:total_spend::NUMBER(18,2) AS total_spend,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM {{ ref('customer') }},
    LATERAL FLATTEN(input => JSON_DATA:customers_data) f
),
customer_transformed AS (
    SELECT
        TRIM(customer_id) AS customer_id,
        INITCAP(REGEXP_REPLACE(TRIM(first_name),'[^A-Za-z ]','')) AS first_name,
        INITCAP(REGEXP_REPLACE(TRIM(last_name),'[^A-Za-z ]','')) AS last_name,
        INITCAP(REGEXP_REPLACE(TRIM(first_name),'[^A-Za-z ]','')||' '||REGEXP_REPLACE(TRIM(last_name),'[^A-Za-z ]','')) AS full_name,
        COALESCE(
            TRY_TO_DATE(birth_date,'YYYY-MM-DD'),
            TRY_TO_DATE(birth_date,'MM-DD-YYYY'),
            TRY_TO_DATE(birth_date,'DD-MM-YYYY'),
            TRY_TO_DATE(birth_date,'MM/DD/YYYY'),
            TRY_TO_DATE(birth_date,'DD/MM/YYYY')
        ) AS birth_date,
        DATEDIFF(YEAR,
            COALESCE(
                TRY_TO_DATE(birth_date,'YYYY-MM-DD'),
                TRY_TO_DATE(birth_date,'MM-DD-YYYY'),
                TRY_TO_DATE(birth_date,'DD-MM-YYYY'),
                TRY_TO_DATE(birth_date,'MM/DD/YYYY'),
                TRY_TO_DATE(birth_date,'DD/MM/YYYY')
            ),
            CURRENT_DATE()
        ) AS customer_age,
        CASE
            WHEN DATEDIFF(YEAR,TRY_TO_DATE(birth_date),CURRENT_DATE()) BETWEEN 18 AND 35 THEN 'Young'
            WHEN DATEDIFF(YEAR,TRY_TO_DATE(birth_date),CURRENT_DATE()) BETWEEN 36 AND 55 THEN 'Middle-aged'
            WHEN DATEDIFF(YEAR,TRY_TO_DATE(birth_date),CURRENT_DATE()) >= 56 THEN 'Senior'
            ELSE 'Unknown'
        END AS customer_segment,
        CASE
            WHEN REGEXP_LIKE(LOWER(TRIM(email)),'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
            THEN LOWER(TRIM(email))
            ELSE NULL
        END AS cleaned_email,
        CASE
            WHEN REGEXP_LIKE(LOWER(TRIM(email)),'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
            THEN 'VALID'
            ELSE 'INVALID'
        END AS email_status,
        REGEXP_REPLACE(phone,'[^0-9]','') AS cleaned_phone,
        CASE
            WHEN LENGTH(REGEXP_REPLACE(phone,'[^0-9]',''))=10 THEN 'VALID'
            ELSE 'INVALID'
        END AS phone_status,
        INITCAP(TRIM(street))||', '||INITCAP(TRIM(city))||', '||UPPER(TRIM(state))||', '||UPPER(TRIM(country))||' - '||TRIM(zip_code) AS standardized_address,
        UPPER(TRIM(income_bracket)) AS income_bracket,
        UPPER(TRIM(loyalty_tier)) AS loyalty_tier,
        INITCAP(TRIM(occupation)) AS occupation,
        COALESCE(marketing_opt_in,FALSE) AS marketing_opt_in,
        INITCAP(TRIM(preferred_communication)) AS preferred_communication,
        INITCAP(TRIM(preferred_payment_method)) AS preferred_payment_method,
        TRY_TO_DATE(registration_date) AS registration_date,
        TRY_TO_DATE(last_purchase_date) AS last_purchase_date,
        TRY_TO_DATE(last_modified_date) AS last_modified_date,
        COALESCE(total_purchases,0) AS total_purchases,
        COALESCE(total_spend,0) AS total_spend,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM customer_flattened
)
SELECT *
FROM customer_transformed
QUALIFY ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY last_modified_date DESC)=1