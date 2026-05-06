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

user_entry_summary as (

    select
        user_id,
        count(*) as total_entries,
        min(entered_at) as first_entry_at
    from entries
    group by 1

),

daily_registrations as (

    select
        cast(u.created_at as date) as date_day,
        u.client_id,
        u.tenant_id,
        t.tenant_name,
        u.game_type,
        count(*) as registered
    from users as u
    inner join tenants as t
        on u.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

),

daily_activations as (

    select
        cast(u.created_at as date) as date_day,
        u.client_id,
        u.tenant_id,
        t.tenant_name,
        u.game_type,
        count(case when ues.first_entry_at is not null then 1 end) as activated,
        count(case when ues.total_entries >= 2 then 1 end) as repeat_entrants
    from users as u
    inner join tenants as t
        on u.tenant_id = t.tenant_id
    left join user_entry_summary as ues
        on u.user_id = ues.user_id
    group by 1, 2, 3, 4, 5

),

joined as (

    select
        dr.date_day,
        dr.client_id,
        dr.tenant_id,
        dr.tenant_name,
        dr.game_type,
        dr.registered,
        coalesce(da.activated, 0) as activated,
        case
            when dr.registered > 0
                then round(coalesce(da.activated, 0) / dr.registered, 4)
            else 0
        end as activation_rate,
        coalesce(da.repeat_entrants, 0) as repeat_entrants,
        case
            when coalesce(da.activated, 0) > 0
                then round(coalesce(da.repeat_entrants, 0) / da.activated, 4)
            else 0
        end as repeat_rate
    from daily_registrations as dr
    left join daily_activations as da
        on dr.date_day = da.date_day
        and dr.tenant_id = da.tenant_id

)

select * from joined
