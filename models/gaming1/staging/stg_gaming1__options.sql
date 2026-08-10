with

source as (

    select *
    from {{ source('gaming1', 'options') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as option_id,
        question_id::varchar as question_id,

        ---------- strings
        option_text_en as option_text,

        ---------- numerics
        display_order,

        ---------- booleans
        is_correct,

        ---------- timestamps
        created_at

    from source

)

select * from renamed
