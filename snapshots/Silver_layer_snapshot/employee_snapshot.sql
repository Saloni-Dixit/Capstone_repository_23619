{% snapshot employee_snapshot %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='employee_id',
        strategy='check',
        check_cols=[
            'full_name',
            'role',
            'work_location',
            'email',
            'phone',
            'performance_rating'
        ]
    )
}}

SELECT
    *
FROM {{ ref('silver_employee') }}

{% endsnapshot %}