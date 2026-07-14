with

spins as (

    select
        user_id,
        cast(spun_at as date) as date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('fct_oddschecker_spintowin__spins') }}

),

users as (

    select
        user_id,
        external_user_id,
        oc_plus_reward_status,
        oc_plus_reward_variant
    from {{ ref('dim_oddschecker_spintowin__users') }}

),

active_days as (

    select
        user_id,
        date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        count(*) as spins
    from spins
    group by 1, 2, 3, 4, 5, 6

)

select
    ad.user_id,
    ad.date_day,
    ad.client_id,
    ad.tenant_id,
    ad.tenant_name,
    ad.game_type,
    ad.spins,
    u.external_user_id,
    u.oc_plus_reward_status,
    u.oc_plus_reward_variant
from active_days as ad
left join users as u
    on ad.user_id = u.user_id
