-- Each day's reveal window opens on its own day but stays open until the round ends, so users can
-- catch up on missed days: "the contest day in progress" at a time is the latest day already open.
with

contest_days as (

    select *
    from {{ ref('stg_gaming1__squads_contest_days') }}

),

contests as (

    select *
    from {{ ref('int_gaming1__contests_unioned') }}

)

select
    d.contest_day_id,
    d.contest_id,
    c.client_id,
    c.tenant_id,
    c.tenant_name,
    d.game_type,
    d.day_index,
    d.reveal_starts_at,
    d.reveal_ends_at,
    cast(convert_timezone('UTC', '{{ var("local_timezone") }}', d.reveal_starts_at) as date) as reveal_start_date_uk,
    d.created_at,
    d.updated_at
from contest_days as d
left join contests as c
    on d.contest_id = c.contest_id
