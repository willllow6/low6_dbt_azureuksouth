with

source as (

    select *
    from {{ source('tipman_pickem', 'user_selections') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as selection_id,
        user_id::varchar as user_id,
        pickem_id::varchar as contest_id,
        user_id::varchar || '-' || pickem_id::varchar as entry_id,
        question_id::varchar as question_id,
        option_id::varchar as option_id,

        ---------- strings
        'tipman' as client_id,
        'pickem' as game_type,

        ---------- numerics
        try_to_number(substr(custom_value, 0, 5)) as tiebreaker_prediction,
        points_earned as points,

        ---------- booleans

        ---------- timestamps
        created_at as selected_at,
        created_at,
        updated_at

    from source

)

select * from renamed
