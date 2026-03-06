with

user_promos as (

    select *
    from {{ ref('fct_prizekings_comps__user_promotions') }}
    where is_used = true
),

promos as (

    select *
    from {{ ref('dim_prizekings_comps__promotions') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

)

select
    user_promos.user_promotion_id,
    user_promos.user_id,
    user_promos.promotion_id,
    user_promos.promotion_code,
    user_promos.promotion_status,
    user_promos.max_uses,
    user_promos.is_used,
    user_promos.completed_at,
    promos.promotion_type,
    promos.bonus_type,
    promos.qualification_value,
    promos.reward_value,
    promos.is_active,
    promos.starts_at,
    promos.ends_at,
    tenants.tenant_name,
    user_promos.created_at
from user_promos 
inner join promos 
    on user_promos.promotion_id = promos.promotion_id
inner join tenants 
    on promos.tenant_id = tenants.tenant_id