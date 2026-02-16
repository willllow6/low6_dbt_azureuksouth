with

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

)

select
    cast(users.created_at as date) as registration_date,
    tenants.tenant_name,
    users.roles,
    users.is_active,
    count(*) as registrations
from users
left join tenants 
    on users.tenant_id = tenants.tenant_id
group by 1,2,3,4
