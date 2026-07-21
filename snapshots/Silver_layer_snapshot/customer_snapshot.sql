{% snapshot customer_snapshot %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='customer_id',
        strategy='check',
        check_cols=[
            'first_name',
            'last_name',
            'full_name',
            'birth_date',
            'cleaned_email',
            'cleaned_phone',
            'standardized_address',
            'income_bracket',
            'loyalty_tier',
            'occupation',
            'marketing_opt_in',
            'preferred_communication',
            'preferred_payment_method',
            'customer_segment'
        ]
    )
}}

SELECT
    *
FROM {{ ref('silver_customer') }}

{% endsnapshot %}