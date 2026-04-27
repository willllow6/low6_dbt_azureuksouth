with

source as (

    select *
    from {{ source('tipman_pickem', 'pickem_leaderboards') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as contest_leaderboard_id,
        user_id::varchar as user_id,
        pickem_id::varchar as contest_id,

        ---------- strings
        'tipman' as client_id,
        'pickem' as game_type,

        ---------- numerics
        points,
        rank as leaderboard_position,
        tiebreaker_margin,

        ---------- booleans

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed
