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
    external_user_id,
    email,
    free_spins,
    spins_consumed,
    oc_plus_reward_status,
    oc_plus_reward_variant,
    is_active,
    oc_plus_reward_granted_at,
    locked_at,
    unlocked_at,
    created_at
from users
