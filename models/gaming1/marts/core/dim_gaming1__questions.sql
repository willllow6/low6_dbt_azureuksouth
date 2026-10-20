with

questions as (

    select *
    from {{ ref('stg_gaming1__questions') }}

)

select
    question_id,
    contest_id,
    'gaming1' as client_id,
    'pickem' as game_type,
    question_text,
    question_type,
    correct_value,
    points,
    voided,
    voided_reason,
    created_at
from questions
