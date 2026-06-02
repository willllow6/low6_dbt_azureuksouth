with

users as (

    select *
    from {{ ref('stg_engagecraft_fantasy__users') }}

)

select
    user_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    engagecraft_id,
    ref_id,
    username,
    favourite_club_id,
    country_code,
    created_at,
    updated_at,
    last_login_at
from users
