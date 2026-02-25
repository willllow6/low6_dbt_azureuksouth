with

source as (

    select *
    from {{ source('itv_spinoff_live','playeranswers') }}

),

renamed as (

    select

        ----------  ids
        id as player_answer_id,
        playerid as player_id,
        livequizquestionid as live_quiz_question_id,

        ---------- strings
        answer,

        ---------- numerics
    
        ---------- booleans
        iscorrect as is_correct,

        ---------- dates
        cast(answeredat as date) as answered_date,

        ---------- timestamps
        answeredat as answered_at

    from source

)

select * from renamed