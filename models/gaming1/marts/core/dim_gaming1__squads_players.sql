with

players as (

    select *
    from {{ ref('stg_gaming1__squads_players') }}

)

select
    player_id,
    competition_id,
    client_id,
    game_type,
    player_external_id,
    player_name,
    first_name,
    last_name,
    player_position,
    team_external_id,
    team_code,
    rarity,
    gpg,
    player_status,
    image_url,
    created_at,
    updated_at
from players
