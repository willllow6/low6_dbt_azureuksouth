with

snapshots as (

    select *
    from {{ ref('stg_engagecraft_fantasy__team_matchday_snapshots') }}

)

select
    snapshot_id,
    fantasy_team_id,
    matchday_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    total_points,
    matchday_rank,
    created_at,
    updated_at
from snapshots
