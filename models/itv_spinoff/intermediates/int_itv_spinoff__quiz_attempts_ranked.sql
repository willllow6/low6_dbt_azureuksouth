select
    *,
    row_number() over(
            partition by user_id
            order by attempted_at
        ) as user_attempt_number
from {{ ref('int_itv_spinoff__quiz_attempts_unioned') }}