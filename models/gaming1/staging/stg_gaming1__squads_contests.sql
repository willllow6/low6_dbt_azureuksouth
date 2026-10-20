-- Source table squads_rounds: a round is the canonical contest a user enters.
with

source as (

    select *
    from {{ source('gaming1', 'squads_rounds') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as contest_id,
        contest_id::varchar as competition_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,
        name as contest_name,
        slug as contest_slug,
        status as contest_status,

        ---------- numerics
        sequence as round_sequence,
        reveal_count,
        min_gpg,
        max_gpg,

        ---------- timestamps
        convert_timezone('UTC', match_window_ends_at)::timestamp_ntz as match_window_ends_at,
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
