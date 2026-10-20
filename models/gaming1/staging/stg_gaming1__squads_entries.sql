-- Source table squads_user_rounds: one row per user per round entered.
with

source as (

    select *
    from {{ source('gaming1', 'squads_user_rounds') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as entry_id,
        round_id::varchar as contest_id,
        user_id::varchar as user_id,
        prize_id::varchar as prize_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,
        status as entry_status,

        ---------- numerics
        score,
        rank as final_rank,
        goal_count,
        shot_count,
        tackle_count,
        interception_count,

        ---------- timestamps
        convert_timezone('UTC', created_at)::timestamp_ntz as entered_at,
        convert_timezone('UTC', locked_at)::timestamp_ntz as locked_at,
        convert_timezone('UTC', scored_at)::timestamp_ntz as settled_at,
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
