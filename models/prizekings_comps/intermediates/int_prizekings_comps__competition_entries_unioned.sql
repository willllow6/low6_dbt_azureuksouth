with

stb_entries as (

    select *
    from {{ ref('stg_prizekings_comps__competition_entry') }}

),

draw_entries as (

    select *
    from {{ ref('stg_prizekings_comps__user_raffle_tickets') }}

),

unioned as (

    select
        entry_sk,
        competition_sk,
        user_id,
        prize_sk,
        is_winner,
        created_at
    from stb_entries

    union all

    select
        entry_sk,
        competition_sk,
        user_id,
        prize_sk,
        is_winner,
        created_at
    from draw_entries

)

select * from unioned