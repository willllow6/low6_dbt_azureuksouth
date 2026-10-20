-- One account covers every gaming1 game; every user is attributed to pickem (game_type).
-- tenant_id / tenant_name are resolved via int_gaming1__user_tenants: the platform's only tenant
-- while there is one, else location / first entry / client_id -- see that model for why.
with

users as (

    select *
    from {{ ref('stg_gaming1__users') }}

),

user_tenants as (

    select *
    from {{ ref('int_gaming1__user_tenants') }}

)

select
    users.user_id,
    users.client_id,
    user_tenants.tenant_id,
    user_tenants.tenant_name,
    users.game_type,
    users.registered_at,
    cast(convert_timezone('UTC', '{{ var("local_timezone") }}', users.registered_at) as date) as registered_date_uk,
    users.registration_type,
    users.external_user_id,
    users.username,
    users.email,
    users.country,
    users.state,
    users.location,
    users.favourite_team_id,
    users.referral_code
from users
left join user_tenants
    on users.user_id = user_tenants.user_id
