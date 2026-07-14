with

spins as (

    select
        user_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        date_trunc('week', cast(convert_timezone('UTC', '{{ var("local_timezone") }}', spun_at) as date)) as activity_week
    from {{ ref('fct_oddschecker_spintowin__spins') }}

),

cohort_weeks as (

    select
        user_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        min(activity_week) as cohort_week
    from spins
    group by 1, 2, 3, 4, 5

),

cohort_sizes as (

    select
        cohort_week,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        count(distinct user_id) as cohort_size
    from cohort_weeks
    group by 1, 2, 3, 4, 5

),

user_cohort_activity as (

    select
        cw.cohort_week,
        cw.client_id,
        cw.tenant_id,
        cw.tenant_name,
        cw.game_type,
        s.activity_week,
        datediff(week, cw.cohort_week, s.activity_week) as weeks_since_cohort,
        count(distinct cw.user_id) as retained_users
    from cohort_weeks as cw
    inner join spins as s
        on cw.user_id = s.user_id
        and cw.client_id = s.client_id
        and cw.tenant_id = s.tenant_id
        and cw.tenant_name = s.tenant_name
        and cw.game_type = s.game_type
    group by 1, 2, 3, 4, 5, 6, 7

),

retention as (

    select
        uca.cohort_week,
        uca.activity_week,
        uca.client_id,
        uca.tenant_id,
        uca.tenant_name,
        uca.game_type,
        uca.weeks_since_cohort,
        cs.cohort_size,
        uca.retained_users,
        case
            when cs.cohort_size > 0
                then round(uca.retained_users / cs.cohort_size, 4)
            else 0
        end as retention_rate
    from user_cohort_activity as uca
    inner join cohort_sizes as cs
        on uca.cohort_week = cs.cohort_week
        and uca.client_id = cs.client_id
        and uca.tenant_id = cs.tenant_id
        and uca.tenant_name = cs.tenant_name
        and uca.game_type = cs.game_type

)

select * from retention
