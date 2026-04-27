with

source as (

    select *
    from {{ source('tipman_pickem', 'options') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as option_id,
        question_id::varchar as question_id,

        ---------- strings
        option_text_en as option_text,

        ---------- numerics

        ---------- booleans
        is_correct,

        ---------- timestamps
        start_utc as starts_at,
        created_at

    from source

)

select * from renamed
