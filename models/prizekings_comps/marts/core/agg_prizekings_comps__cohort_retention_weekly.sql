with

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

entries as (

    select *
    from {{ ref('fct_prizekings_comps__entries') }}

),

user_cohorts as (

    select
        u.user_id,
        u.client_id,
        u.tenant_id,
        u.game_type,
        dateadd(day, -(dayofweek(u.created_at) - 1), cast(u.created_at as date)) as cohort_week
    from users as u

),

user_activity_weeks as (

    select
        e.user_id,
        dateadd(day, -(dayofweek(e.entered_at) - 1), cast(e.entered_at as date)) as activity_week
    from entries as e
    group by 1, 2

),

cohort_activity as (

    select
        uc.cohort_week,
        uc.client_id,
        uc.tenant_id,
        uc.game_type,
        uaw.activity_week,
        datediff(week, uc.cohort_week, uaw.activity_week) as weeks_since_cohort,
        count(distinct uc.user_id) as retained_users
    from user_cohorts as uc
    inner join user_activity_weeks as uaw
        on uc.user_id = uaw.user_id
    group by 1, 2, 3, 4, 5, 6

),

cohort_sizes as (

    select
        cohort_week,
        tenant_id,
        count(*) as cohort_size
    from user_cohorts
    group by 1, 2

),

joined as (

    select
        ca.cohort_week,
        ca.client_id,
        ca.tenant_id,
        t.tenant_name,
        ca.game_type,
        ca.weeks_since_cohort,
        cs.cohort_size,
        ca.retained_users,
        case
            when cs.cohort_size > 0
                then round(ca.retained_users / cs.cohort_size, 4)
            else 0
        end as retention_rate
    from cohort_activity as ca
    inner join cohort_sizes as cs
        on ca.cohort_week = cs.cohort_week
        and ca.tenant_id = cs.tenant_id
    inner join tenants as t
        on ca.tenant_id = t.tenant_id

)

select * from joined
