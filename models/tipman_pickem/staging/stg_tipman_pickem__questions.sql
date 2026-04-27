with

source as (

    select *
    from {{ source('tipman_pickem', 'questions') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as question_id,
        pickem_id::varchar as contest_id,

        ---------- strings
        question_text_en as question_text,
        question_type,

        ---------- numerics
        correct_value,
        points,

        ---------- booleans

        ---------- timestamps
        start_utc as starts_at,
        created_at

    from source

)

select * from renamed
