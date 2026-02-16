with

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

daily_registration_metrics as (

    select
        cast(users.created_at as date) as registration_date,
        tenants.tenant_name,
        count(*) as registrations
    from users
    inner join tenants 
        on users.tenant_id = tenants.tenant_id
    group by 1,2

)

select * from daily_registration_metrics


