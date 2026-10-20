-- One row per UK day per client × tenant × game_type, from that game's first activity day
-- (not before gaming1_start_date) to today.
-- dau/wau/mau count users active (entered or picked; squads also revealed) on the day / trailing
-- 7 / 28 days. One account covers every gaming1 game; every user is attributed to pickem
-- (dim_gaming1__users.game_type), so all registrations sit on the pickem row and are null on
-- squads (matches agg_low6__game_metrics_daily).
with

users as (

    select *
    from {{ ref('dim_gaming1__users') }}

),

entries as (

    select *
    from {{ ref('fct_gaming1__entries') }}

),

activity as (

    select *
    from {{ ref('fct_gaming1__user_activity_daily') }}

),

date_spine as (

    select dateadd(day, seq4(), '{{ var("gaming1_start_date") }}'::date) as date_day
    from table(generator(rowcount => 3660))
    where dateadd(day, seq4(), '{{ var("gaming1_start_date") }}'::date)
        <= cast(convert_timezone('UTC', '{{ var("local_timezone") }}', sysdate()) as date)

),

combos as (

    select
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        min(activity_date_uk)               as first_activity_date
    from activity
    group by 1, 2, 3, 4

),

spine as (

    select
        d.date_day,
        c.client_id,
        c.tenant_id,
        c.tenant_name,
        c.game_type
    from date_spine as d
    inner join combos as c
        on d.date_day >= c.first_activity_date

),

registrations as (

    select
        registered_date_uk                  as date_day,
        tenant_id,
        game_type,
        count(*)                            as registrations
    from users
    group by 1, 2, 3

),

entry_metrics as (

    select
        entry_date_uk                       as date_day,
        tenant_id,
        game_type,
        count(*)                            as entries,
        count_if(user_entry_number = 1)     as first_entries,
        count_if(user_platform_entry_number = 1) as first_platform_entries
    from entries
    group by 1, 2, 3

),

active_users as (

    select
        s.date_day,
        s.tenant_id,
        s.game_type,
        count(distinct case when a.activity_date_uk = s.date_day then a.user_id end) as dau,
        count(distinct case when a.activity_date_uk > dateadd(day, -7, s.date_day) then a.user_id end) as wau,
        count(distinct a.user_id)           as mau
    from spine as s
    inner join activity as a
        on  s.tenant_id = a.tenant_id
        and s.game_type = a.game_type
        and a.activity_date_uk between dateadd(day, -27, s.date_day) and s.date_day
    group by 1, 2, 3

),

final as (

    select
        s.date_day,
        s.client_id,
        s.tenant_id,
        s.tenant_name,
        s.game_type,
        -- null on game_types users are never attributed to (squads)
        case when s.game_type = 'pickem' then coalesce(r.registrations, 0) end as registrations,
        coalesce(e.entries, 0)              as entries,
        coalesce(a.dau, 0)                  as dau,
        coalesce(a.wau, 0)                  as wau,
        coalesce(a.mau, 0)                  as mau,
        coalesce(e.first_entries, 0)        as first_entries,
        -- extension: first entry in any gaming1 game (first_entries is first in this game_type)
        coalesce(e.first_platform_entries, 0) as first_platform_entries
    from spine as s
    left join registrations as r
        on s.date_day = r.date_day and s.tenant_id = r.tenant_id and s.game_type = r.game_type
    left join entry_metrics as e
        on s.date_day = e.date_day and s.tenant_id = e.tenant_id and s.game_type = e.game_type
    left join active_users as a
        on s.date_day = a.date_day and s.tenant_id = a.tenant_id and s.game_type = a.game_type

)

select
    date_day,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    registrations,
    entries,
    dau,
    wau,
    mau,
    first_entries,
    first_platform_entries
from final
