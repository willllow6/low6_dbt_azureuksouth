with

stb_prize_awards as (

    select *
    from {{ ref('stg_prizekings_comps__competition_entry') }}
    where prize_id is not null

),

draw_prize_awards as (

    select *
    from {{ ref('stg_prizekings_comps__user_raffle_tickets') }}
    where prize_id is not null

),

unioned as (

    select
        entry_sk,
        competition_sk,
        user_id,
        prize_sk
    from stb_prize_awards

    union all

    select
        entry_sk,
        competition_sk,
        user_id,
        prize_sk
    from draw_prize_awards

)

select * from unioned