with

prize_tiers as (

    select *
    from {{ ref('stg_oddschecker_spintowin__prize_tiers') }}

)

select
    prize_tier_id,
    client_id,
    game_type,
    prize_tier_name,
    prize_tier_type,
    level,
    amount,
    monthly_limit,
    inventory_period_type,
    display_order,
    created_at,
    updated_at
from prize_tiers
