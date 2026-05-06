with

entries as (

    select *
    from {{ ref('mart_prizekings_comps__entries') }}

),

financials as (

    select *
    from {{ ref('agg_prizekings_comps__contest_financials') }}

),

contest_metrics as (

    select
        contest_sk,
        client_id,
        game_type,
        tenant_name,
        contest_name,
        contest_type,
        contest_status,
        entry_fee,
        starts_at,
        ends_at,
        count(*) as total_entry_count,
        sum(case when user_entry_number = 1 then 1 else 0 end) as first_user_entries,
        sum(case when prize_type in ('main', 'second') then 1 else 0 end) as tangible_prize_count,
        sum(case when prize_type = 'main' then 1 else 0 end) as main_prize_count,
        sum(case when prize_type = 'second' then 1 else 0 end) as second_prize_count,
        coalesce(sum(case when prize_type in ('main', 'second') then prize_value else 0 end), 0) as tangible_prize_value,
        coalesce(sum(case when prize_type = 'main' then prize_value else 0 end), 0) as main_prize_value,
        coalesce(sum(case when prize_type = 'second' then prize_value else 0 end), 0) as second_prize_value
    from entries
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

),

add_financials as (

    select
        c.contest_sk,
        c.client_id,
        c.game_type,
        c.tenant_name,
        c.contest_name,
        c.contest_type,
        c.contest_status,
        c.entry_fee,
        c.starts_at,
        c.ends_at,
        c.total_entry_count,
        c.first_user_entries,
        c.tangible_prize_count,
        c.main_prize_count,
        c.second_prize_count,
        c.tangible_prize_value,
        c.main_prize_value,
        c.second_prize_value,
        coalesce(f.paid_entry_count, 0) as paid_entry_count,
        coalesce(f.free_entry_count, 0) as free_entry_count,
        coalesce(f.free_entry_count, 0) * c.entry_fee as free_entry_value,
        coalesce(f.gross_entry_revenue, 0) as gross_entry_revenue,
        coalesce(f.cash_entry_revenue, 0) as cash_entry_revenue,
        coalesce(f.credit_entry_revenue, 0) as credit_entry_revenue,
        coalesce(f.credit_prize_count, 0) as credit_prize_count,
        coalesce(f.credit_prize_value, 0) as credit_prize_value
    from contest_metrics as c
    left join financials as f
        on c.contest_sk = f.contest_sk

)

select
    contest_sk,
    client_id,
    game_type,
    tenant_name,
    contest_name,
    contest_type,
    contest_status,
    entry_fee,
    starts_at,
    ends_at,
    total_entry_count,
    first_user_entries,
    paid_entry_count,
    free_entry_count,
    free_entry_value,
    gross_entry_revenue,
    cash_entry_revenue,
    credit_entry_revenue,
    tangible_prize_count,
    main_prize_count,
    second_prize_count,
    credit_prize_count,
    tangible_prize_count + credit_prize_count as total_prize_count,
    tangible_prize_value,
    main_prize_value,
    second_prize_value,
    credit_prize_value,
    tangible_prize_value + credit_prize_value as gross_prize_value,
    gross_entry_revenue - tangible_prize_value - credit_prize_value as gross_profit,
    cash_entry_revenue - tangible_prize_value as cash_profit
from add_financials
