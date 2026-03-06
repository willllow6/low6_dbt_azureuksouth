with

stb_prizes as (

    select *
    from {{ ref('stg_prizekings_comps__competition_prize') }}

),

draw_prizes as (

    select *
    from {{ ref('stg_prizekings_comps__prizes') }}

),

unioned as (

    select
        prize_sk,
        competition_sk,
        prize_type,
        quantity,
        value
    from stb_prizes

    union all

    select
        prize_sk,
        competition_sk,
        prize_type,
        quantity,
        value
    from draw_prizes

)

select * from unioned