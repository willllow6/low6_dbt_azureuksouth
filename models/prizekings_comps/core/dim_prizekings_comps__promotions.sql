select
    promotion_id,
    promotion_type,
    bonus_type,
    qualification_value,
    reward_value,
    is_active,
    starts_at,
    ends_at,
    created_at,
    updated_at
from {{ ref('stg_prizekings_comps__promotions') }}