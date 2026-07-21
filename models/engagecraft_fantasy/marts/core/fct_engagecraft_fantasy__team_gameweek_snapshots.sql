with

snapshots as (

    select *
    from {{ ref('stg_engagecraft_fantasy__team_gameweek_snapshots') }}

)

select
    snapshot_id,
    fantasy_team_id,
    gameweek_id,
    active_captain_id,
    active_vice_captain_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    gameweek_number,
    total_points,
    gameweek_rank,
    goals_scored,
    assists,
    created_at,
    updated_at
from snapshots
