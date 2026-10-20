-- Source table squads_round_days: the days within a round on which a user reveals cards and picks.
with

source as (

    select *
    from {{ source('gaming1', 'squads_round_days') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as contest_day_id,
        round_id::varchar as contest_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,

        ---------- numerics
        day_index,

        ---------- timestamps
        convert_timezone('UTC', reveal_start)::timestamp_ntz as reveal_starts_at,
        convert_timezone('UTC', reveal_end)::timestamp_ntz as reveal_ends_at,
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
