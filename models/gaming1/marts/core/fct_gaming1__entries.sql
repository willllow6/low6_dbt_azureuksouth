with

entries as (

    select *
    from {{ ref('int_gaming1__selection_entries') }}

)

select
    entry_id,
    user_id,
    contest_id,
    client_id,
    tenant_id,
    game_type,
    total_points,
    tiebreaker_prediction,
    tiebreaker_outcome,
    entered_at,
    entry_number,
    is_winner
from entries
