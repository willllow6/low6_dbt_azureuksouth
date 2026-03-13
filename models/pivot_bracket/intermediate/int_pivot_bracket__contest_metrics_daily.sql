select
    created_date_et,
    count(*) as contests_created
from {{ ref('dim_pivot_bracket__contests') }}
group by 1