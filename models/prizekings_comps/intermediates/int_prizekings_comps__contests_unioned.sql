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
        contest_sk,
        tenant_id,
        client_id,
        game_type,
        contest_type,
        contest_status,
        is_active,
        entry_fee,
        starts_at,
        ends_at,
        created_at,
        updated_at
    from stb_comps

    union all

    select
        contest_sk,
        tenant_id,
        client_id,
        game_type,
        contest_type,
        contest_status,
        is_active,
        entry_fee,
        starts_at,
        ends_at,
        created_at,
        updated_at
    from draw_comps

)

select * from unioned
