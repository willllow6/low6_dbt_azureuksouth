-- Resolves tenant_id and tenant_name from the user's location field (location = leagues.code = tenant_code).
with

users as (

    select *
    from {{ ref('stg_tipman_pickem__users') }}

),

tenants as (

    select
        tenant_id,
        tenant_code,
        tenant_name
    from {{ ref('stg_tipman_pickem__tenants') }}

),

joined as (

    select
        users.user_id,
        users.client_id,
        coalesce(tenants.tenant_id, users.client_id) as tenant_id,
        coalesce(tenants.tenant_name, users.client_id) as tenant_name,
        users.game_type,
        users.registration_type,
        users.external_user_id,
        users.username,
        users.email,
        users.country,
        users.state,
        users.location,
        users.registered_at
    from users
    left join tenants
        on users.location = tenants.tenant_code

)

select * from joined
