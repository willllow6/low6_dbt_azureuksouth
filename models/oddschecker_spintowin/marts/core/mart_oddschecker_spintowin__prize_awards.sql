with

prize_awards as (

    select *
    from {{ ref('fct_oddschecker_spintowin__prize_awards') }}

),

users as (

    select
        user_id,
        external_user_id,
        oc_plus_reward_status,
        oc_plus_reward_variant
    from {{ ref('dim_oddschecker_spintowin__users') }}

)

select
    pa.activity_id,
    pa.user_id,
    pa.prize_tier_id,
    pa.prize_type,
    pa.prize_name,
    pa.prize_amount,
    pa.client_id,
    pa.tenant_id,
    pa.tenant_name,
    pa.game_type,
    pa.status,
    pa.awarded_at,
    u.external_user_id,
    u.oc_plus_reward_status,
    u.oc_plus_reward_variant
from prize_awards as pa
left join users as u
    on pa.user_id = u.user_id
