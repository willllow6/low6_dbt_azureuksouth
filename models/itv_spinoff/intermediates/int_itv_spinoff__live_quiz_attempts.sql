select
    user_id,
    live_quiz_id as quiz_id,
    count(*) as answered_questions,
    sum(case when is_correct then 1 else 0 end) as total_points,
    min(answered_date) as attempt_date,
    hour(min(answered_at)) as attempt_hour,
    min(answered_at) as attempted_at
from {{ ref('int_itv_spinoff__live_quiz_answers') }}
group by 1,2

