-- Source table squads_user_slot_candidates: the cards shown to a user for a slot.
with

source as (

    select *
    from {{ source('gaming1', 'squads_user_slot_candidates') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as candidate_id,
        user_slot_id::varchar as slot_id,
        player_id::varchar as player_id,

        ---------- strings
        'gaming1' as client_id,
        'squads' as game_type,

        ---------- numerics
        position as card_position,

        ---------- booleans
        is_selected,

        ---------- timestamps
        convert_timezone('UTC', selected_at)::timestamp_ntz as selected_at,
        convert_timezone('UTC', created_at)::timestamp_ntz as created_at,
        convert_timezone('UTC', updated_at)::timestamp_ntz as updated_at

    from source

)

select * from renamed
