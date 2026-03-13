select
    s.selection_id,
    s.entry_id,
    e.user_id,
    e.contest_id,
    s.match_id,
    s.selected_team_id,
    t.team_name as selected_team_name,
    s.is_correct,
    s.created_date,
    s.created_at,
    s.updated_at
from {{ ref('stg_pivot_bracket__selections') }} as s 
left join {{ ref('stg_pivot_bracket__teams') }} as t 
    on s.selected_team_id = t.team_id
left join {{ ref('stg_pivot_bracket__entries') }} as e 
    on s.entry_id = e.entry_id