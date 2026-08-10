-- Grain change: stg_gaming1__selections (selection grain) -> entry grain (one row per user per contest).
-- entry_id is a surrogate key on (user_id, contest_id). Named "selection_entries" (not "entries") so a
-- future gaming1 game type can add its own int_gaming1__<type>_entries and union into fct_gaming1__entries
-- without reshaping this model, mirroring draftkings' selection_entries + daily_reveal_entries pattern.

with

selections as (

    select *
    from {{ ref('stg_gaming1__selections') }}

),

contests as (

    select
        contest_id,
        tenant_id
    from {{ ref('stg_gaming1__contests') }}

),

tiebreaker_outcomes as (

    select
        contest_id,
        correct_value as tiebreaker_outcome
    from {{ ref('stg_gaming1__questions') }}
    where question_type = 'tiebreaker'

),

entry_grain as (

    select
        user_id,
        contest_id,
        client_id,
        game_type,
        sum(points) as total_points,
        max(tiebreaker_prediction) as tiebreaker_prediction,
        min(selected_at) as entered_at
    from selections
    group by
        user_id,
        contest_id,
        client_id,
        game_type

),

with_entry_number as (

    select
        user_id || '-' || contest_id as entry_id,
        user_id,
        contest_id,
        client_id,
        game_type,
        total_points,
        tiebreaker_prediction,
        entered_at,
        row_number() over (
            partition by user_id
            order by entered_at
        ) as entry_number
    from entry_grain

),

with_context as (

    select
        entries.entry_id,
        entries.user_id,
        entries.contest_id,
        entries.client_id,
        contests.tenant_id,
        entries.game_type,
        entries.total_points,
        entries.tiebreaker_prediction,
        tiebreakers.tiebreaker_outcome,
        entries.entered_at,
        entries.entry_number,
        null::boolean as is_winner  -- TODO: derive from leaderboard once results are scored
    from with_entry_number as entries
    left join contests
        on entries.contest_id = contests.contest_id
    left join tiebreaker_outcomes as tiebreakers
        on entries.contest_id = tiebreakers.contest_id

)

select * from with_context
