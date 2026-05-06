with

source as (

    select *
    from {{ source('prizekings_comps','prizes') }}

),

renamed as (

    select

        ----------  ids
        id as prize_id,
        'DRAW_' || id as prize_sk,
        raffle_id as contest_id,
        'DRAW_' || raffle_id as contest_sk,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        prize_type,

        ---------- numerics
        quantity,
        prize_value as value,
        assigned_count,

        ---------- booleans

        ---------- dates

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed