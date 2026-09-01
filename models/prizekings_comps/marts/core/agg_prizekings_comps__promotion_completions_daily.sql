with

base as (

    select *
    from {{ ref('mart_prizekings_comps__promotion_completions') }}

),

daily as (

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
    from base
    group by
        completed_date,
        tenant_name,
        promotion_type,
        bonus_type,
        qualification_value,
        reward_value,
        is_active,
        starts_at,
        ends_at

)

select * from daily
