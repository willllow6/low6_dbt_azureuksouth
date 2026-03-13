select
    created_date_et,
    count(*) as new_customers
from {{ ref('dim_pivot_bracket__customers') }}
group by 1