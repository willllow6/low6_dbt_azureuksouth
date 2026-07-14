with

activities as (

    select *
    from {{ ref('stg_oddschecker_spintowin__activities') }}

)

select
    activity_id,
    user_id,
    prize_tier_id,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    feedback,
    is_winner,
    prize_type,
    prize_name,
    created_at as spun_at
from activities
