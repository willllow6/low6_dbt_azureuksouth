select 
    created_date_et,
    count(*) as registrations
from {{ ref('dim_pivot_bracket__users') }}
group by 1