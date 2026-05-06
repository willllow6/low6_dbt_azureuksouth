with

stb_tangible_prize_awards as (

    select
        e.entry_sk,
        e.contest_sk,
        e.user_id,
        e.client_id,
        e.game_type,
        e.prize_sk,
        p.prize_type,
        p.value as prize_value,
        e.updated_at as awarded_at
    from {{ ref('stg_prizekings_comps__competition_entry') }} as e
    inner join {{ ref('stg_prizekings_comps__competition_prize') }} as p
        on e.prize_sk = p.prize_sk
    where e.prize_id is not null
    and p.prize_type != 'instant'

),

draw_tangible_prize_awards as (

    select
        e.entry_sk,
        e.contest_sk,
        e.user_id,
        e.client_id,
        e.game_type,
        e.prize_sk,
        p.prize_type,
        p.value as prize_value,
        e.updated_at as awarded_at
    from {{ ref('stg_prizekings_comps__user_raffle_tickets') }} as e
    inner join {{ ref('stg_prizekings_comps__prizes') }} as p
        on e.prize_sk = p.prize_sk
    where e.prize_id is not null
    and p.prize_type != 'instant'

),

instant_win_prize_awards as (

    select
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        'instant' as prize_type,
        amount as prize_value,
        created_at as awarded_at
    from {{ ref('stg_prizekings_comps__transactions') }}
    where prize_sk is not null

),

unioned as (

    select
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        prize_type,
        prize_value,
        awarded_at
    from stb_tangible_prize_awards

    union all

    select
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        prize_type,
        prize_value,
        awarded_at
    from draw_tangible_prize_awards

    union all

    select
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        prize_type,
        prize_value,
        awarded_at
    from instant_win_prize_awards

),

with_pk as (

    select
        md5(concat_ws('|',
            coalesce(entry_sk, ''),
            coalesce(prize_sk, ''),
            coalesce(prize_type, '')
        )) as prize_award_id,
        entry_sk,
        contest_sk,
        user_id,
        client_id,
        game_type,
        prize_sk,
        prize_type,
        prize_value,
        awarded_at
    from unioned

)

select * from with_pk
