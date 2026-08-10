-- tenant_id / tenant_name are resolved via int_gaming1__user_tenants (location match, falling back
-- to the user's first entry, falling back to client_id) -- see that model for why.
with

users as (

    select *
    from {{ ref('stg_gaming1__users') }}

),

user_tenants as (

    select *
    from {{ ref('int_gaming1__user_tenants') }}

),

joined as (

    select
        users.user_id,
        users.client_id,
        user_tenants.tenant_id,
        user_tenants.tenant_name,
        users.game_type,
        users.registration_type,
        users.external_user_id,
        users.username,
        users.email,
        users.country,
        users.state,
        users.location,
        users.referral_code,
        users.registered_at
    from users
    left join user_tenants
        on users.user_id = user_tenants.user_id

)

select * from joined
