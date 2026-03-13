select 
    entry_date_et,
    count(*) as entries
from {{ ref('fct_pivot_bracket__entries') }}
group by 1