select
    cast(completed_at as date) as completed_date,
    tenant_name,
    promotion_type,
    bonus_type,
    qualification_value,
    reward_value,
    is_active,
    starts_at,
    ends_at,
    count(*) as promo_completions
from {{ ref('mart_prizekings_comps__promotion_completions') }}
group by 1,2,3,4,5,6,7,8,9
