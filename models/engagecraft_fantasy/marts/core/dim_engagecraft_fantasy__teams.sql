with

teams as (

    select *
    from {{ ref('stg_engagecraft_fantasy__teams') }}

)

select
    team_id,
    tournament_id,
    country_id,
    opta_team_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    team_name,
    team_short_name,
    team_code,
    team_flag_key,
    shirt_key,
    country,
    country_flag_key,
    tournament_group,
    is_national_team,
    is_eliminated,
    created_at,
    updated_at
from teams
