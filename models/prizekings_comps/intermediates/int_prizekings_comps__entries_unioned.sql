with

stb_entries as (

    select *
    from {{ ref('stg_prizekings_comps__competition_entry') }}

),

draw_entries as (

    select *
    from {{ ref('stg_prizekings_comps__user_raffle_tickets') }}

),

contests as (

    select
        contest_sk,
        tenant_id
    from {{ ref('int_prizekings_comps__contests_unioned') }}

),

unioned as (

    select
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        is_winner,
        entered_at,
        created_at
    from stb_entries

    union all

    select
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        is_winner,
        entered_at,
        created_at
    from draw_entries

),

with_tenant as (

    select
        u.entry_sk,
        u.contest_sk,
        u.user_id,
        u.client_id,
        u.game_type,
        c.tenant_id,
        u.prize_sk,
        u.is_winner,
        u.entered_at,
        u.created_at
    from unioned as u
    inner join contests as c
        on u.contest_sk = c.contest_sk

)

select * from with_tenant
