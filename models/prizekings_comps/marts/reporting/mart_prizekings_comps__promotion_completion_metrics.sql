with

user_promos as (

    select *
    from {{ ref('fct_prizekings_comps__user_promotions') }}
    where is_used = true
),

promos as (

    select *
    from {{ ref('dim_prizekings_comps__promotions') }}

)

select
    cast(completed_at as date) as completed_date,
    promotion_type,
    bonus_type,
    qualification_value,
    reward_value,
    is_active,
    starts_at,
    ends_at,
    count(*) as promo_completions
from user_promos 
inner join promos 
    on user_promos.promotion_id = promos.promotion_id
group by 1,2,3,4,5,6,7,8
