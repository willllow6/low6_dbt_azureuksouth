with

entries as (

    select *
    from {{ ref('mart_prizekings_comps__entries') }}

),

daily_entries as (

    select
        cast(entered_at as date) as date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        count(*) as total_entries,
        sum(case when user_entry_number = 1 then 1 else 0 end) as first_user_entries,
        sum(case when is_winner then 1 else 0 end) as total_winning_entries
    from entries
    group by 1, 2, 3, 4, 5

)

select * from daily_entries
