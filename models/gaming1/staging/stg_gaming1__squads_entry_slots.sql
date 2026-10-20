-- Source table squads_user_slots: one slot per round day per entry; player_id is the pick.
with

source as (

    select *
    from {{ source('gaming1', 'squads_user_slots') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as slot_id,
        user_round_id::varchar as entry_id,
        round_day_id::varchar as contest_day_id,
        player_id::varchar as player_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,
        status as slot_status,
        revealed_rarity,

        ---------- numerics
        day_index,
        goal_count,
        shot_count,
        tackle_count,
        interception_count,

        ---------- timestamps
        convert_timezone('UTC', revealed_at)::timestamp_ntz as revealed_at,
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
