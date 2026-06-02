with

tournaments as (

    select *
    from {{ ref('stg_engagecraft_fantasy__tournaments') }}

)

select
    tournament_id,
    opta_tournament_calendar_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    tournament_name,
    season_label,
    tournament_format,
    tournament_status,
    is_active,
    budget_currency,
    squad_size,
    starting_xi_size,
    max_transfers,
    transfer_limit_per_gameweek,
    extra_transfer_penalty_points,
    max_per_club,
    max_per_country,
    starts_at,
    ends_at,
    created_at,
    updated_at
from tournaments
