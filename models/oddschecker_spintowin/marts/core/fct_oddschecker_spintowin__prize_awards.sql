with

activities as (

    select *
    from {{ ref('stg_oddschecker_spintowin__activities') }}
    where is_winner = true

),

prize_tiers as (

    select
        prize_tier_id,
        amount
    from {{ ref('dim_oddschecker_spintowin__prize_tiers') }}

)

select
    a.activity_id,
    a.user_id,
    a.prize_tier_id,
    a.prize_type,
    a.prize_name,
    pt.amount as prize_amount,
    a.client_id,
    a.tenant_id,
    a.tenant_name,
    a.game_type,
    case when a.is_claimed then 'claimed' else 'awarded' end as status,
    a.created_at as awarded_at
from activities as a
left join prize_tiers as pt
    on a.prize_tier_id = pt.prize_tier_id
