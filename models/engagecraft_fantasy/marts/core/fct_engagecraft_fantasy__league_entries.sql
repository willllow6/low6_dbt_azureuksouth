with

league_entries as (

    select *
    from {{ ref('stg_engagecraft_fantasy__league_entries') }}

)

select
    league_entry_id,
    league_id,
    user_id,
    fantasy_team_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    league_points,
    league_rank,
    gameweek,
    joined_at
from league_entries
