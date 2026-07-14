with

spins as (

    select *
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

prize_tiers as (

    select
        prize_tier_id,
        prize_tier_name,
        prize_tier_type,
        amount
    from {{ ref('dim_oddschecker_spintowin__prize_tiers') }}

)

select
    s.activity_id,
    s.user_id,
    s.prize_tier_id,
    s.client_id,
    s.tenant_id,
    s.tenant_name,
    s.game_type,
    s.feedback,
    s.is_winner,
    s.prize_type,
    s.prize_name,
    s.spun_at,
    u.external_user_id,
    u.oc_plus_reward_status,
    u.oc_plus_reward_variant,
    pt.prize_tier_name,
    pt.prize_tier_type,
    pt.amount as prize_amount
from spins as s
left join users as u
    on s.user_id = u.user_id
left join prize_tiers as pt
    on s.prize_tier_id = pt.prize_tier_id
