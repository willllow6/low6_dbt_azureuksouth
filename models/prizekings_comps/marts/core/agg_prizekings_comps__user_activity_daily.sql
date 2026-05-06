with

entries as (

    select *
    from {{ ref('fct_prizekings_comps__entries') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

entry_metrics as (

    select
        cast(entries.entered_at as date) as date_day,
        entries.client_id,
        entries.tenant_id,
        t.tenant_name,
        entries.game_type,
        count(distinct entries.user_id) as dau
    from entries
    inner join tenants as t
        on entries.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

),

registrations as (

    select
        date_day,
        tenant_id,
        sum(new_registrations) as new_registrations
    from {{ ref('agg_prizekings_comps__registration_metrics_daily') }}
    group by 1, 2

),

joined as (

    select
        e.date_day,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.dau,
        coalesce(r.new_registrations, 0) as new_registrations,
        e.dau - coalesce(r.new_registrations, 0) as returning_users
    from entry_metrics as e
    left join registrations as r
        on e.date_day = r.date_day
        and e.tenant_id = r.tenant_id

)

select * from joined
