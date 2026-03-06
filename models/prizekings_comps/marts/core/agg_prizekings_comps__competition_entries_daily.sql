select
    cast(created_at as date) as entry_date,
    tenant_name,
    count(*) as total_entries,
    sum(case when user_entry_number = 1 then 1 else 0 end) as first_user_entries,
    sum(case when is_winner then 1 else 0 end ) as total_winning_entries
from {{ ref('mart_prizekings_comps__competition_entries') }}
group by 1,2