with

transfers as (

    select *
    from {{ ref('stg_engagecraft_fantasy__fantasy_team_transfers') }}

)

select
    transfer_id,
    fantasy_team_id,
    source_matchday_id,
    target_matchday_id,
    player_in_id,
    player_out_id,
    superseded_by_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    transfer_status,
    gameweek,
    scheduled_at,
    applied_at,
    conflict_resolved_at,
    undone_at,
    created_at
from transfers
