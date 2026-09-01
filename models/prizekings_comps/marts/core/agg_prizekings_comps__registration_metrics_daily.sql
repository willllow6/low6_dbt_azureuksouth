with

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

registration_metrics as (

    select
        cast(u.created_at as date) as date_day,
        u.client_id,
        u.tenant_id,
        t.tenant_name,
        u.game_type,
        'form' as registration_type,
        count(*) as new_registrations,
        0 as profile_completions,
        0 as marketing_consents
    from users as u
    inner join tenants as t
        on u.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5, 6

)

select * from registration_metrics
