with

selections as (

    select *
    from {{ ref('int_engagecraft_fantasy__gameweek_selections') }}

)

select
    fantasy_team_id || '-' || gameweek_id || '-' || fantasy_player_id as selection_id,
    fantasy_team_id,
    gameweek_id,
    gameweek_number,
    fantasy_player_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    position_slot,
    entry_type,
    is_starter,
    is_captain,
    is_vice_captain
from selections
