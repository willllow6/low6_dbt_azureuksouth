select
    m.match_id,
    m.tournament_id,
    m.region_id,
    m.round_id,
    m.home_team_id,
    m.away_team_id,
    m.winner_team_id,
    tor.tournament_name,
    reg.region_name,
    r.round_name,
    r.round_number,
    t1.team_name as home_team_name,
    t2.team_name as away_team_name,
    t3.team_name as winning_team_name,
    m.match_slot
from {{ ref('stg_pivot_bracket__matches')}} as m
left join {{ ref('stg_pivot_bracket__tournaments')}} as tor 
    on m.tournament_id = tor.tournament_id 
left join {{ ref('stg_pivot_bracket__regions')}} as reg 
    on m.region_id = reg.region_id
left join {{ ref('stg_pivot_bracket__rounds')}} as r 
    on m.round_id = r.round_id 
left join {{ ref('stg_pivot_bracket__teams')}} as t1
    on m.home_team_id = t1.team_id
left join {{ ref('stg_pivot_bracket__teams')}} as t2
    on m.away_team_id = t2.team_id
left join {{ ref('stg_pivot_bracket__teams')}} as t3
    on m.winner_team_id = t3.team_id
