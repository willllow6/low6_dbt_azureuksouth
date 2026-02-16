with

date_generator as (

    select dateadd(day, seq4(), '2026-01-23'::date) as date_day
    from table(generator(rowcount => 600))
    where dateadd(day, seq4(), '2026-01-23'::date) <= current_date()

),

tenants as (

    select
        tenant_name
    from {{ ref('dim_prizekings_comps__tenants') }}

),

registrations as (

    select *
    from {{ ref('int_prizekings_comps__daily_registration_metrics') }}

),

user_activity as (

    select *
    from {{ ref('int_prizekings_comps__daily_user_activity') }}

),

entries as (

    select *
    from {{ ref('int_prizekings_comps__daily_entry_metrics') }}

),

deposits as (

    select *
    from {{ ref('int_prizekings_comps__daily_deposit_metrics') }}

),

financials as (

    select *
    from {{ ref('int_prizekings_comps__daily_financial_metrics') }}
    
),

date_tenants as (

    select
        date_day,
        tenant_name
    from date_generator
    join tenants

),

joined as (

    select
        dt.date_day,
        dt.tenant_name,
        coalesce(r.registrations,0) as registrations,
        coalesce(ua.active_players,0) as active_players,
        coalesce(e.total_entries,0) as total_entries,
        coalesce(e.first_user_entries,0) as first_user_entries,
        coalesce(e.total_winning_entries,0) as total_winning_entries,
        coalesce(d.total_deposits,0) as total_deposits,
        coalesce(d.first_time_depositors,0) as first_time_depositors,
        coalesce(d.total_deposit_amount,0) as total_deposit_amount,
        coalesce(f.gross_entry_revenue,0) as gross_entry_revenue,
        coalesce(f.cash_entry_revenue,0) as cash_entry_revenue,
        coalesce(f.credit_entry_spend,0) as credit_entry_spend,
        coalesce(f.total_prize_value_awarded,0) as total_prize_value_awarded,
        coalesce(f.cash_prize_value_awarded,0) as cash_prize_value_awarded,
        coalesce(f.credit_prize_value_awarded,0) as credit_prize_value_awarded,
        coalesce(f.gross_profit,0) as gross_profit
    from date_tenants as dt 
    left join registrations as r 
        on dt.date_day = r.registration_date
        and dt.tenant_name = r.tenant_name
    left join user_activity as ua 
        on dt.date_day = ua.activity_date
        and dt.tenant_name = ua.tenant_name
    left join entries as e 
        on dt.date_day = e.entry_date
        and dt.tenant_name = e.tenant_name
    left join deposits as d 
        on dt.date_day = d.deposit_date
        and dt.tenant_name = d.tenant_name
    left join financials as f 
        on dt.date_day = f.transaction_date
        and dt.tenant_name = f.tenant_name

)

select * from joined



