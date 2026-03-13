select
    tournament_name,
    region_name,
    round_name,
    round_number,
    home_team_name,
    away_team_name,
    contest_name,
    contest_status,
    contest_type,
    customer_name,
    selected_team_name,
    is_correct,
    count(*) as selections
from {{ ref('mart_pivot_bracket__selections') }}
group by 1,2,3,4,5,6,7,8,9,10,11,12
