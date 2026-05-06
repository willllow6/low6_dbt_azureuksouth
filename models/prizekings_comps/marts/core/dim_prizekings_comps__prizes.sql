with

stb_prizes as (

    select *
    from {{ ref('stg_prizekings_comps__competition_prize') }}

),

draw_prizes as (

    select *
    from {{ ref('stg_prizekings_comps__prizes') }}

),

draw_prize_names as (

    select *
    from {{ ref('stg_prizekings_comps__translations') }}
    where prize_id is not null

),

draw_prizes_combined as (

    select
        draw_prizes.prize_sk,
        draw_prizes.contest_sk,
        draw_prizes.client_id,
        draw_prizes.game_type,
        draw_prizes.prize_type,
        draw_prizes.quantity,
        draw_prize_names.translation_name as prize_name,
        draw_prizes.value
    from draw_prizes
    inner join draw_prize_names
        on draw_prizes.prize_id = draw_prize_names.prize_id

),

unioned as (

    select
        prize_sk,
        contest_sk,
        client_id,
        game_type,
        prize_type,
        quantity,
        prize_name,
        value
    from stb_prizes

    union all

    select
        prize_sk,
        contest_sk,
        client_id,
        game_type,
        prize_type,
        quantity,
        prize_name,
        value
    from draw_prizes_combined

)

select * from unioned
