with

source as (

    select *
    from {{ source('prizekings_comps','user_raffle_tickets') }}

),

renamed as (

    select

        ----------  ids
        id as entry_id,
        'DRAW_' || id as entry_sk,
        raffle_id as contest_id,
        'DRAW_' || raffle_id as contest_sk,
        transaction_id,
        user_id,
        prize_id,
        case
            when prize_id is not null
                then 'DRAW_' || prize_id
            else null
        end as prize_sk,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        ticket,

        ---------- numerics

        ---------- booleans
        is_winner,

        ---------- dates

        ---------- timestamps
        created_at as entered_at,
        created_at,
        updated_at

    from source

)

select * from renamed