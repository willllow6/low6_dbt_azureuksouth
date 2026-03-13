select
    entry_date_et,
    hour(entered_at_et) as entry_hour_et,
    contest_name,
    contest_status,
    contest_type,
    contest_starts_at_et,
    customer_name,
    tournament_name,
    tournament_status,
    count(*) as entries
from {{ ref('mart_pivot_bracket__entries') }}
group by 1,2,3,4,5,6,7,8,9