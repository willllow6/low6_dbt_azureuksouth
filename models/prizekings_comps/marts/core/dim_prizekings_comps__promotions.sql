with

promotions as (

    select *
    from {{ ref('stg_prizekings_comps__promotions') }}

),

promotion_tenants as (

    select *
    from {{ ref('stg_prizekings_comps__promotion_tenants') }}

)

select
    promotions.promotion_id,
    promotion_tenants.tenant_id,
    promotions.promotion_type,
    promotions.bonus_type,
    promotions.qualification_value,
    promotions.reward_value,
    promotions.is_active,
    promotions.starts_at,
    promotions.ends_at,
    promotions.created_at,
    promotions.updated_at
from promotions
left join promotion_tenants
    on promotions.promotion_id = promotion_tenants.promotion_id
