select
        entry_id,
        user_id,
        contest_id,
        tiebreaker_selection,
        points,
        created_date as entry_date,
        created_date_et as entry_date_et,
        created_at as entered_at,
        created_at_et as entered_at_et,
        updated_at
from {{ ref('stg_pivot_bracket__entries') }}