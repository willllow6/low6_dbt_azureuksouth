with

contests as (

    select *
    from {{ ref('stg_tipman_pickem__contests') }}

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('stg_tipman_pickem__tenants') }}

),

joined as (

    select
        contests.contest_id,
        contests.client_id,
        contests.tenant_id,
        tenants.tenant_name,
        contests.game_type,
        contests.contest_name,
        contests.contest_status,
        contests.is_active,
        contests.is_scored,
        contests.prize_text,
        contests.opens_at,
        contests.starts_at,
        contests.created_at,
        contests.updated_at
    from contests
    left join tenants
        on contests.tenant_id = tenants.tenant_id

)

select * from joined
