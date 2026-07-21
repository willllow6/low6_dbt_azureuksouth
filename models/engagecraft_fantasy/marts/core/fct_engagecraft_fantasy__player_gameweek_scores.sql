with

scores as (

    select *
    from {{ ref('stg_engagecraft_fantasy__player_gameweek_scores') }}

)

select
    player_gameweek_id,
    fantasy_player_id,
    gameweek_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    gameweek_number,
    gameweek_points,
    goal_bonus_normal_points,
    goal_bonus_captain_points,
    minutes_played,
    ppm_points,
    stats,
    breakdown,
    max_captain_reached_at,
    created_at,
    updated_at
from scores
