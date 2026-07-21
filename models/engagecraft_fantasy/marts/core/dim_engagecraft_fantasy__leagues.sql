with

leagues as (

    select *
    from {{ ref('stg_engagecraft_fantasy__leagues') }}

)

select
    league_id,
    tournament_id,
    commissioner_user_id,
    regenerated_from_league_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    league_name,
    description,
    join_code,
    league_type,
    is_public,
    is_celebrity,
    roll_over_league,
    country_code,
    club_id,
    start_gameweek,
    created_at,
    updated_at
from leagues
