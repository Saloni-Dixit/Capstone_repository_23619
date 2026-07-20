{{ config(materialized='table') }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS employee_key,
    employee_id,
    full_name,
    role,
    work_location,
    tenure_years,
    email,
    phone,
    performance_rating,
    sales_target,
    current_sales,
    target_achievement_percentage,
    department,
    employment_status,
    manager_id,
    hire_date,
    date_of_birth
FROM {{ ref('silver_employee') }}