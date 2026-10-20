-- Squads only. One row per contest per cohort day index per activity day index.
--   cohort_day_index    contest day in progress when the user entered (the latest day whose reveal
--                       had started; day 0 if they entered before the round opened)
--   activity_day_index  contest day in progress when the user made a pick
--   retained_users      cohort users who made at least one pick during activity_day_index
-- Uses the day in progress, not the picked slot's own day_index: reveal windows stay open until
-- the round ends, so a late joiner can pick every earlier day's slot in one sitting.
-- days_since_cohort = 0 is not always 100%: it's the share of entrants who picked on their entry day.
-- Only contest days that have already opened are included.
with

entries as (

    select *
    from {{ ref('fct_gaming1__entries') }}
    where game_type = 'squads'

),

selections as (

    select *
    from {{ ref('fct_gaming1__selections') }}
    where game_type = 'squads'

),

contests as (

    select *
    from {{ ref('dim_gaming1__contests') }}

),

contest_days as (

    select *
    from {{ ref('dim_gaming1__squads_contest_days') }}

),

opened_days as (

    select *
    from contest_days
    where reveal_starts_at <= sysdate()

),

first_days as (

    select
        contest_id,
        min(day_index)                          as first_day_index
    from contest_days
    group by 1

),

user_cohorts as (

    select
        e.contest_id,
        e.user_id,
        coalesce(max(d.day_index), min(f.first_day_index)) as cohort_day_index
    from entries as e
    inner join first_days as f
        on e.contest_id = f.contest_id
    left join contest_days as d
        on  e.contest_id = d.contest_id
        and d.reveal_starts_at <= e.entered_at
    group by 1, 2

),

selection_days as (

    select
        s.contest_id,
        s.user_id,
        s.selection_id,
        max(d.day_index)                        as activity_day_index
    from selections as s
    inner join contest_days as d
        on  s.contest_id = d.contest_id
        and d.reveal_starts_at <= s.selected_at
    group by 1, 2, 3

),

user_activity as (

    select
        contest_id,
        user_id,
        activity_day_index,
        count(*)                                as selections
    from selection_days
    group by 1, 2, 3

),

cohorts as (

    select
        contest_id,
        cohort_day_index,
        count(*)                                as cohort_size
    from user_cohorts
    group by 1, 2

),

cohort_activity as (

    select
        c.contest_id,
        c.cohort_day_index,
        a.activity_day_index,
        count(*)                                as retained_users,
        sum(a.selections)                       as selections
    from user_cohorts as c
    inner join user_activity as a
        on  c.contest_id = a.contest_id
        and c.user_id = a.user_id
        and a.activity_day_index >= c.cohort_day_index
    group by 1, 2, 3

),

spine as (

    select
        c.contest_id,
        c.cohort_day_index,
        c.cohort_size,
        d.day_index                             as activity_day_index,
        d.reveal_starts_at                      as activity_day_starts_at
    from cohorts as c
    inner join opened_days as d
        on  c.contest_id = d.contest_id
        and d.day_index >= c.cohort_day_index

),

final as (

    select
        s.contest_id,
        ct.client_id,
        ct.tenant_id,
        ct.tenant_name,
        ct.game_type,
        ct.contest_name,
        s.cohort_day_index,
        s.activity_day_index,
        s.activity_day_index - s.cohort_day_index                   as days_since_cohort,
        s.cohort_size,
        coalesce(a.retained_users, 0)                               as retained_users,
        round(coalesce(a.retained_users, 0) / s.cohort_size, 4)     as retention_rate,
        coalesce(a.selections, 0)                                   as selections,
        s.activity_day_starts_at
    from spine as s
    inner join contests as ct
        on s.contest_id = ct.contest_id
    left join cohort_activity as a
        on  s.contest_id = a.contest_id
        and s.cohort_day_index = a.cohort_day_index
        and s.activity_day_index = a.activity_day_index

)

select
    contest_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    contest_name,
    cohort_day_index,
    activity_day_index,
    days_since_cohort,
    cohort_size,
    retained_users,
    retention_rate,
    selections,
    activity_day_starts_at
from final
