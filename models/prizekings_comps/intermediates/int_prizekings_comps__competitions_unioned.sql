with

stb_comps as (

    select *
    from {{ ref('stg_prizekings_comps__competition') }}

),

draw_comps as (

    select *
    from {{ ref('stg_prizekings_comps__raffles') }}

),

unioned as (

    select
        competition_sk,
        tenant_id,
        competition_type,
        competition_status,
        entry_price,
        starts_at,
        ends_at,
        created_at,
        updated_at
    from stb_comps

    union all 

    select
        competition_sk,
        tenant_id,
        competition_type,
        competition_status,
        entry_price,
        starts_at,
        ends_at,
        created_at,
        updated_at
    from draw_comps

)

select * from unioned