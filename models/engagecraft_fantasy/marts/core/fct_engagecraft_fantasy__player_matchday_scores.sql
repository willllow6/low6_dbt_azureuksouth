with

scores as (

    select *
    from {{ ref('stg_engagecraft_fantasy__player_matchday_scores') }}

)

select
    player_matchday_id,
    fantasy_player_id,
    matchday_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    matchday_points,
    goal_bonus_normal_points,
    goal_bonus_captain_points,
    minutes_played,
    bonus_points,
    stats,
    max_captain_reached_at,
    created_at,
    updated_at
from scores
