with

selections as (

    select *
    from {{ ref('stg_engagecraft_fantasy__selections') }}

)

select
    selection_id,
    fantasy_team_id,
    fantasy_player_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    is_starter,
    is_captain,
    is_vice_captain,
    position_slot,
    created_at
from selections
