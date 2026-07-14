with

users as (

    select *
    from {{ ref('stg_oddschecker_spintowin__users') }}

)

select
    user_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    'sso' as registration_type,
    external_user_id,
    created_at as registered_at
from users
