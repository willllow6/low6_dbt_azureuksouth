with

entries as (

    select *
    from {{ ref('mart_seven_days__entries') }}

),

entry_metrics as (

    select
        session_date            as date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        game_name,
        game_description,
        prize_tier,
        is_played,
        prize_name,
        prize_type,
        prize_odds,
        count(*)                as entries,
        sum(
            case when user_entry_number = 1 then 1 else 0 end
        )                       as first_entries,
        count(prize_id)         as prizes,
        sum(ticket_price)       as total_sales
    from entries
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

)

select * from entry_metrics
