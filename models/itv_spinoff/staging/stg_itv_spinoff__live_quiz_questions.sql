with

source as (

    select *
    from {{ source('itv_spinoff_live','livequizquestions') }}

),

renamed as (

    select

        ----------  ids
        id as live_quiz_question_id,
        questionid as question_id,
        livequizid as live_quiz_id,
        brandid as brand_id,

        ---------- strings

        ---------- numerics
        orderindex as order_index,
    
        ---------- booleans
        active as is_active

        ---------- dates

        ---------- timestamps

    from source

)

select * from renamed