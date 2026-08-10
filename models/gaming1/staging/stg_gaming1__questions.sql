with

source as (

    select *
    from {{ source('gaming1', 'questions') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as question_id,
        pickem_id::varchar as contest_id,

        ---------- strings
        question_text_en as question_text,
        question_type,
        voided_reason,

        ---------- numerics
        correct_value,
        points,

        ---------- booleans
        voided,

        ---------- timestamps
        created_at

    from source

)

select * from renamed
