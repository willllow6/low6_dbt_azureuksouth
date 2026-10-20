-- One row per tenant × game_type per first-entry cohort week per activity week (UK weeks, Monday
-- start). retained_users = cohort users active (entered or picked; squads also revealed) in
-- activity_week. Users who never entered are excluded.
with

entries as (

    select *
    from {{ ref('fct_gaming1__entries') }}

),

activity as (

    select *
    from {{ ref('fct_gaming1__user_activity_daily') }}

),

user_cohorts as (

    select
        tenant_id,
        game_type,
        user_id,
        min(date_trunc('week', entry_date_uk))  as cohort_week
    from entries
    group by 1, 2, 3

),

user_weeks as (

    select distinct
        tenant_id,
        game_type,
        user_id,
        date_trunc('week', activity_date_uk)    as activity_week
    from activity

),

tenants as (

    select distinct
        client_id,
        tenant_id,
        coalesce(tenant_name, client_id)        as tenant_name,
        game_type
    from entries

),

cohorts as (

    select
        tenant_id,
        game_type,
        cohort_week,
        count(*)                                as cohort_size
    from user_cohorts
    group by 1, 2, 3

),

weeks as (

    select distinct
        tenant_id,
        game_type,
        activity_week
    from user_weeks

),

cohort_activity as (

    select
        c.tenant_id,
        c.game_type,
        c.cohort_week,
        w.activity_week,
        count(*)                                as retained_users
    from user_cohorts as c
    inner join user_weeks as w
        on  c.tenant_id = w.tenant_id
        and c.game_type = w.game_type
        and c.user_id = w.user_id
        and w.activity_week >= c.cohort_week
    group by 1, 2, 3, 4

),

spine as (

    select
        c.tenant_id,
        c.game_type,
        c.cohort_week,
        w.activity_week,
        c.cohort_size
    from cohorts as c
    inner join weeks as w
        on  c.tenant_id = w.tenant_id
        and c.game_type = w.game_type
        and w.activity_week >= c.cohort_week

),

final as (

    select
        s.cohort_week,
        s.activity_week,
        t.client_id,
        s.tenant_id,
        t.tenant_name,
        s.game_type,
        datediff(week, s.cohort_week, s.activity_week)              as weeks_since_cohort,
        s.cohort_size,
        coalesce(a.retained_users, 0)                               as retained_users,
        round(coalesce(a.retained_users, 0) / s.cohort_size, 4)     as retention_rate
    from spine as s
    inner join tenants as t
        on  s.tenant_id = t.tenant_id
        and s.game_type = t.game_type
    left join cohort_activity as a
        on  s.tenant_id = a.tenant_id
        and s.game_type = a.game_type
        and s.cohort_week = a.cohort_week
        and s.activity_week = a.activity_week

)

select
    cohort_week,
    activity_week,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    weeks_since_cohort,
    cohort_size,
    retained_users,
    retention_rate
from final
