-- cohort_week = Monday of the week the user made their first entry.
-- retained_users = users in that cohort who made at least one entry in the given week.
-- week 0 is always 100% by definition (the cohort is defined by first entry).
with

entries as (

    select
        user_id,
        client_id,
        tenant_id,
        game_type,
        date_trunc('week', cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date)) as activity_week
    from {{ ref('fct_tipman_pickem__entries') }}

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('stg_tipman_pickem__tenants') }}

),

entries_with_names as (

    select
        e.user_id,
        e.client_id,
        e.tenant_id,
        coalesce(t.tenant_name, e.client_id) as tenant_name,
        e.game_type,
        e.activity_week
    from entries as e
    left join tenants as t
        on e.tenant_id = t.tenant_id

),

cohort_weeks as (

    select
        user_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        min(activity_week) as cohort_week
    from entries_with_names
    group by
        user_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type

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
    group by
        cohort_week,
        client_id,
        tenant_id,
        tenant_name,
        game_type

),

user_cohort_activity as (

    select
        e.user_id,
        cw.client_id,
        cw.tenant_id,
        cw.tenant_name,
        cw.game_type,
        cw.cohort_week,
        e.activity_week,
        datediff('week', cw.cohort_week, e.activity_week) as weeks_since_cohort
    from entries_with_names as e
    join cohort_weeks as cw
        on e.user_id = cw.user_id
        and e.client_id = cw.client_id
        and e.tenant_id = cw.tenant_id
        and e.tenant_name = cw.tenant_name
        and e.game_type = cw.game_type

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
        count(distinct uca.user_id) as retained_users
    from user_cohort_activity as uca
    join cohort_sizes as cs
        on uca.cohort_week = cs.cohort_week
        and uca.client_id = cs.client_id
        and uca.tenant_id = cs.tenant_id
        and uca.tenant_name = cs.tenant_name
        and uca.game_type = cs.game_type
    group by
        uca.cohort_week,
        uca.activity_week,
        uca.client_id,
        uca.tenant_id,
        uca.tenant_name,
        uca.game_type,
        uca.weeks_since_cohort,
        cs.cohort_size

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
    round(retained_users / nullif(cohort_size, 0), 4) as retention_rate
from retention
