with

booster_activations as (

    select *
    from {{ ref('stg_engagecraft_fantasy__gameweek_boosters') }}

)

select
    gameweek_booster_id,
    fantasy_team_id,
    gameweek_id,
    booster_id,
    player_12th_man_id,
    max_captain_player_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    max_captain_points,
    is_cancelled,
    processed,
    max_captain_reached_at,
    activated_at,
    created_at,
    updated_at
from booster_activations
