with

player_answers as (

    select * 
    from {{ ref('stg_itv_spinoff__player_answers') }}

),

players as (

    select * 
    from {{ ref('stg_itv_spinoff__players') }}

),

live_quiz_questions as (


    select *
    from {{ ref('stg_itv_spinoff__live_quiz_questions') }}

),

joined as (

    select
        pa.player_answer_id,
        pa.player_id,
        p.user_id,
        pa.live_quiz_question_id,
        q.question_id,
        q.live_quiz_id,
        q.brand_id,
        pa.answer,
        pa.is_correct,
        q.is_active as question_is_active,
        pa.answered_date,
        pa.answered_at
    from player_answers as pa
    inner join players as p 
        on pa.player_id = p.player_id
    inner join live_quiz_questions as q 
        on pa.live_quiz_question_id = q.live_quiz_question_id 

)

select * from joined