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
    u.user_id,
    u.tenant_id,
    u.client_id,
    u.game_type,
    u.first_name,
    u.last_name,
    u.email,
    u.mobile,
    u.roles,
    u.balance,
    u.is_active,
    t.tenant_name,
    u.created_at,
    u.updated_at
from users as u
left join tenants as t
    on u.tenant_id = t.tenant_id
