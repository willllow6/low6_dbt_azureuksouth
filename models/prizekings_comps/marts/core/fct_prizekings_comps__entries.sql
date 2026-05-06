with

entries as (

    select *
    from {{ ref('int_prizekings_comps__entries_unioned') }}

),

ranked as (

    select
        *,
        row_number() over (partition by user_id order by entered_at) as user_entry_number
    from entries

)

select
    entry_sk,
    contest_sk,
    user_id,
    client_id,
    game_type,
    tenant_id,
    prize_sk,
    is_winner,
    user_entry_number,
    entered_at,
    created_at
from ranked
