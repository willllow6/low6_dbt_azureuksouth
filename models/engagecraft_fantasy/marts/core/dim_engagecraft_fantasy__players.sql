with

players as (

    select *
    from {{ ref('int_engagecraft_fantasy__players_enriched') }}

)

select
    fantasy_player_id,
    player_id,
    tournament_id,
    team_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    full_name,
    first_name,
    last_name,
    playing_position,
    fantasy_position,
    nationality,
    nationality_flag_key,
    date_of_birth,
    team_name,
    team_short_name,
    tournament_group,
    shirt_number,
    squad_position,
    price,
    ownership_pct,
    availability_display,
    is_visible,
    price_change_up,
    price_change_down,
    created_at,
    updated_at
from players
