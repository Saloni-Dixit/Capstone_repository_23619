WITH employee_flattened AS (
    SELECT
        f.value:employee_id::STRING AS employee_id,
        f.value:first_name::STRING AS first_name,
        f.value:last_name::STRING AS last_name,
        f.value:email::STRING AS email,
        f.value:phone::STRING AS phone,
        f.value:hire_date::STRING AS hire_date,
        f.value:role::STRING AS role,
        f.value:department::STRING AS department,
        f.value:employment_status::STRING AS employment_status,
        f.value:manager_id::STRING AS manager_id,
        f.value:work_location::STRING AS work_location,
        f.value:salary::NUMBER(18,2) AS salary,
        f.value:sales_target::NUMBER(18,2) AS sales_target,
        f.value:current_sales::NUMBER(18,2) AS current_sales,
        f.value:performance_rating::NUMBER(10,2) AS performance_rating,
        f.value:education::STRING AS education,
        f.value:date_of_birth::STRING AS date_of_birth,
        f.value:last_modified_date::STRING AS last_modified_date,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM {{ ref('employee') }},
    LATERAL FLATTEN(input => JSON_DATA:employees_data) f
),
employee_transformed AS (
    SELECT
        TRIM(employee_id) AS employee_id,
        INITCAP(REGEXP_REPLACE(TRIM(first_name),'[^A-Za-z ]','')) AS first_name,
        INITCAP(REGEXP_REPLACE(TRIM(last_name),'[^A-Za-z ]','')) AS last_name,
        INITCAP(TRIM(first_name)||' '||TRIM(last_name)) AS full_name,
        CASE
            WHEN REGEXP_LIKE(LOWER(TRIM(email)),'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
            THEN LOWER(TRIM(email))
            ELSE NULL
        END AS email,
        CASE
            WHEN LENGTH(REGEXP_REPLACE(phone,'[^0-9]','')) = 10
            THEN REGEXP_REPLACE(phone,'[^0-9]','')
            ELSE NULL
        END AS phone,
        COALESCE(
            TRY_TO_DATE(hire_date,'YYYY-MM-DD'),
            TRY_TO_DATE(hire_date,'MM-DD-YYYY'),
            TRY_TO_DATE(hire_date,'DD-MM-YYYY')
        ) AS hire_date,
        DATEDIFF(YEAR,TRY_TO_DATE(hire_date),CURRENT_DATE()) AS tenure_years,
        CASE
            WHEN LOWER(TRIM(role))='sales associate' THEN 'Associate'
            WHEN LOWER(TRIM(role))='store manager' THEN 'Manager'
            WHEN LOWER(TRIM(role))='senior manager' THEN 'Senior Manager'
            ELSE INITCAP(TRIM(role))
        END AS role,
        INITCAP(TRIM(department)) AS department,
        INITCAP(TRIM(employment_status)) AS employment_status,
        TRIM(manager_id) AS manager_id,
        UPPER(TRIM(work_location)) AS work_location,
        COALESCE(salary,0) AS salary,
        COALESCE(sales_target,0) AS sales_target,
        COALESCE(current_sales,0) AS current_sales,
        CASE
            WHEN sales_target > 0
            THEN (current_sales / sales_target) * 100
            ELSE NULL
        END AS target_achievement_percentage,
        performance_rating,
        INITCAP(TRIM(education)) AS education,
        TRY_TO_DATE(date_of_birth) AS date_of_birth,
        TRY_TO_DATE(last_modified_date) AS last_modified_date,
        SOURCE_FILE,
        LOAD_TIMESTAMP
    FROM employee_flattened
)
SELECT *
FROM employee_transformed
QUALIFY ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY last_modified_date DESC)=1