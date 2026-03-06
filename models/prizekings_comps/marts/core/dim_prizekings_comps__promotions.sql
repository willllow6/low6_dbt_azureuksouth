select
    p.promotion_id,
    pt.tenant_id,
    p.promotion_type,
    p.bonus_type,
    p.qualification_value,
    p.reward_value,
    p.is_active,
    p.starts_at,
    p.ends_at,
    p.created_at,
    p.updated_at
from {{ ref('stg_prizekings_comps__promotions') }} as p
left join {{ ref('stg_prizekings_comps__promotion_tenants') }} as pt
    on p.promotion_id = pt.promotion_id