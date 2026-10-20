with

candidates as (

    select *
    from {{ ref('stg_gaming1__squads_slot_candidates') }}

),

slots as (

    select *
    from {{ ref('stg_gaming1__squads_entry_slots') }}

),

entries as (

    select *
    from {{ ref('stg_gaming1__squads_entries') }}

),

contests as (

    select *
    from {{ ref('int_gaming1__contests_unioned') }}

),

final as (

    select
        ca.candidate_id                                     as card_reveal_id,
        ca.slot_id,
        s.entry_id,
        e.user_id,
        e.contest_id,
        ca.client_id,
        c.tenant_id,
        c.tenant_name,
        ca.game_type,
        s.contest_day_id,
        s.day_index,
        ca.player_id,
        ca.card_position,
        ca.is_selected,
        s.revealed_at,
        ca.selected_at,
        ca.created_at,
        ca.updated_at
    from candidates as ca
    inner join slots as s
        on ca.slot_id = s.slot_id
    inner join entries as e
        on s.entry_id = e.entry_id
    left join contests as c
        on e.contest_id = c.contest_id

)

select
    card_reveal_id,
    slot_id,
    entry_id,
    user_id,
    contest_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    contest_day_id,
    day_index,
    player_id,
    card_position,
    is_selected,
    revealed_at,
    selected_at,
    created_at,
    updated_at
from final
