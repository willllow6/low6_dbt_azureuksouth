-- Grain change: session (purchase) → entry (one row per individual ticket play).
-- Flattens the ticket_array JSON from stg_seven_days__sessions into one row per entry.

with

sessions as (

    select *
    from {{ ref('stg_seven_days__sessions') }}

),

entries as (

    select
        s.session_id,
        s.user_id,
        s.game_id,
        s.client_id,
        s.tenant_id,
        s.tenant_name,
        s.game_type,
        s.site_id,
        s.url,
        s.created_date                                              as session_date,
        s.created_at,
        t.index + 1                                                 as session_entry_number,
        t.value:id::string                                          as entry_id,
        t.value:tier::int                                           as prize_tier,
        t.value:played::boolean                                     as is_played,
        t.value:prize:id::int                                       as prize_id,
        t.value:prize:name::string                                  as prize_name,
        t.value:prize:type::string                                  as prize_type,
        t.value:prize:value::string                                 as prize_odds,
        cast(
            regexp_substr(t.value:prize:value::string, '\\d+$') as int
        )                                                           as prize_odds_denominator,
        1.0 / nullif(
            cast(regexp_substr(t.value:prize:value::string, '\\d+$') as int),
            0
        )                                                           as prize_probability,
        row_number() over (
            partition by s.user_id
            order by s.created_at, t.index
        )                                                           as user_entry_number
    from sessions as s,
        lateral flatten(input => s.ticket_array) as t

)

select * from entries
