with

date_spine as (

    select dateadd('day', seq4(), '{{ var("tipman_start_date") }}'::date) as date_day
    from table(generator(rowcount => 1000))
    where dateadd('day', seq4(), '{{ var("tipman_start_date") }}'::date) <= sysdate()

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('dim_tipman_pickem__tenants') }}

),

registrations as (

    -- Registrations are not tenant-scoped (users register once, then enter any tenant's contests).
    -- Summed across registration_type and tenant to get a total per day.
    select
        date_day,
        sum(new_registrations) as new_registrations
    from {{ ref('agg_tipman_pickem__registration_metrics_daily') }}
    group by date_day

),

user_activity as (

    select *
    from {{ ref('agg_tipman_pickem__user_activity_daily') }}

),

entries as (

    select *
    from {{ ref('agg_tipman_pickem__entry_metrics_daily') }}

),

contests as (

    select *
    from {{ ref('agg_tipman_pickem__contest_metrics_daily') }}

),

date_tenants as (

    select
        date_spine.date_day,
        tenants.tenant_id,
        tenants.tenant_name
    from date_spine
    cross join tenants

),

joined as (

    select
        dt.date_day,
        'tipman' as client_id,
        dt.tenant_id,
        dt.tenant_name,
        'pickem' as game_type,

        coalesce(r.new_registrations, 0) as new_registrations,

        coalesce(ua.dau, 0) as dau,
        coalesce(ua.returning_users, 0) as returning_users,

        coalesce(e.contests_active, 0) as contests_active,
        coalesce(e.total_entries, 0) as total_entries,
        coalesce(e.unique_entrants, 0) as unique_entrants,
        coalesce(e.first_time_entrants, 0) as first_time_entrants,

        coalesce(c.contests_scheduled, 0) as contests_scheduled,
        coalesce(c.contests_live, 0) as contests_live,
        coalesce(c.contests_completed, 0) as contests_completed,
        coalesce(c.avg_entries_per_contest, 0) as avg_entries_per_contest

    from date_tenants as dt
    left join registrations as r
        on dt.date_day = r.date_day
    left join user_activity as ua
        on dt.date_day = ua.date_day
        and dt.tenant_id = ua.tenant_id
    left join entries as e
        on dt.date_day = e.date_day
        and dt.tenant_id = e.tenant_id
    left join contests as c
        on dt.date_day = c.date_day
        and dt.tenant_id = c.tenant_id

)

select * from joined
