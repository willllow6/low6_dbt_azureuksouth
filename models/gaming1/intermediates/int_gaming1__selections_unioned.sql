-- Union of pickem selections (one per user_selections row) and squads selections (one per slot
-- with a player picked; selection_id is the slot id). Tenant comes from the contest.
-- Game-specific columns are null for the other game.
with

pickem_selections as (

    select *
    from {{ ref('stg_gaming1__selections') }}

),

options as (

    select *
    from {{ ref('stg_gaming1__options') }}

),

squads_slots as (

    select *
    from {{ ref('stg_gaming1__squads_entry_slots') }}

),

squads_candidates as (

    select *
    from {{ ref('stg_gaming1__squads_slot_candidates') }}

),

squads_entries as (

    select *
    from {{ ref('stg_gaming1__squads_entries') }}

),

contests as (

    select *
    from {{ ref('int_gaming1__contests_unioned') }}

),

pickem as (

    select
        s.selection_id,
        s.entry_id,
        s.user_id,
        s.contest_id,
        s.client_id,
        s.game_type,
        s.selected_at,
        -- pickem
        s.question_id,
        s.option_id,
        o.option_text                                       as selection_value,
        o.is_correct,
        s.points,
        s.tiebreaker_prediction,
        -- squads
        null::varchar                                       as contest_day_id,
        null::number                                        as day_index,
        null::varchar                                       as player_id,
        null::varchar                                       as revealed_rarity,
        null::number                                        as goal_count,
        null::number                                        as shot_count,
        null::number                                        as tackle_count,
        null::number                                        as interception_count,
        null::timestamp_ntz                                 as revealed_at,
        s.updated_at
    from pickem_selections as s
    left join options as o
        on  s.option_id = o.option_id
        and s.question_id = o.question_id

),

squads_selected_cards as (

    select
        slot_id,
        selected_at
    from squads_candidates
    where is_selected

),

squads as (

    select
        s.slot_id                                           as selection_id,
        s.entry_id,
        e.user_id,
        e.contest_id,
        s.client_id,
        s.game_type,
        sc.selected_at,
        -- pickem
        null::varchar                                       as question_id,
        null::varchar                                       as option_id,
        null::varchar                                       as selection_value,
        null::boolean                                       as is_correct,
        null::number                                        as points,
        null::number                                        as tiebreaker_prediction,
        -- squads
        s.contest_day_id,
        s.day_index,
        s.player_id,
        s.revealed_rarity,
        s.goal_count,
        s.shot_count,
        s.tackle_count,
        s.interception_count,
        s.revealed_at,
        s.updated_at
    from squads_slots as s
    inner join squads_entries as e
        on s.entry_id = e.entry_id
    left join squads_selected_cards as sc
        on s.slot_id = sc.slot_id
    where s.player_id is not null

),

unioned as (

    select * from pickem
    union all
    select * from squads

)

select
    u.selection_id,
    u.entry_id,
    u.user_id,
    u.contest_id,
    u.client_id,
    c.tenant_id,
    c.tenant_name,
    u.game_type,
    u.selected_at,
    u.question_id,
    u.option_id,
    u.selection_value,
    u.is_correct,
    u.points,
    u.tiebreaker_prediction,
    u.contest_day_id,
    u.day_index,
    u.player_id,
    u.revealed_rarity,
    u.goal_count,
    u.shot_count,
    u.tackle_count,
    u.interception_count,
    u.revealed_at,
    u.updated_at
from unioned as u
left join contests as c
    on u.contest_id = c.contest_id
