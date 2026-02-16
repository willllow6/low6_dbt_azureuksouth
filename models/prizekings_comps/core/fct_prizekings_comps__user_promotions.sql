select
    user_promotion_id,
    user_id,
    promotion_id,
    promotion_code,
    promotion_status,
    max_uses,
    is_used,
    completed_at,
    created_at
from {{ ref('stg_prizekings_comps__user_promotions') }}