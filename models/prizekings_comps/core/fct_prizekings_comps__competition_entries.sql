with

entries as (

    select *
    from {{ ref('int_prizekings_comps__competition_entries_unioned') }}

),

ranked as (
    
    select
        *,
        row_number() over (partition by user_id order by created_at) as user_entry_number
    from entries
)

select
    entry_sk,
    competition_sk,
    user_id,
    is_winner,
    user_entry_number,
    created_at
from ranked