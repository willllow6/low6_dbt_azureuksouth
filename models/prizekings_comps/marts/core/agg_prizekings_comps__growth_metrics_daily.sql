with

date_generator as (

    select dateadd(day, seq4(), '{{ var("prizekings_start_date") }}'::date) as date_day
    from table(generator(rowcount => 600))
    where dateadd(day, seq4(), '{{ var("prizekings_start_date") }}'::date) <= sysdate()

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('dim_prizekings_comps__tenants') }}

),

registrations as (

    select *
    from {{ ref('agg_prizekings_comps__registration_metrics_daily') }}

),

user_activity as (

    select *
    from {{ ref('agg_prizekings_comps__user_activity_daily') }}

),

entries as (

    select *
    from {{ ref('agg_prizekings_comps__entry_metrics_daily') }}

),

deposits as (

    select *
    from {{ ref('agg_prizekings_comps__deposit_metrics_daily') }}

),

financials as (

    select *
    from {{ ref('agg_prizekings_comps__entry_financial_metrics_daily') }}

),

bonuses as (

    select *
    from {{ ref('agg_prizekings_comps__bonus_metrics_daily') }}

),

prize_awards as (

    select *
    from {{ ref('agg_prizekings_comps__prize_awards_daily') }}

),

date_tenants as (

    select
        date_day,
        tenant_id,
        tenant_name
    from date_generator
    join tenants

),

joined as (

    select
        dt.date_day,
        dt.tenant_id,
        dt.tenant_name,
        'prizekings' as client_id,
        'prize_competition' as game_type,
        coalesce(r.new_registrations, 0) as registrations,
        coalesce(ua.dau, 0) as active_players,
        coalesce(e.total_entries, 0) as total_entry_count,
        coalesce(e.first_time_entrants, 0) as first_entry_count,
        coalesce(d.total_deposits, 0) as total_deposits,
        coalesce(d.first_time_depositors, 0) as first_time_depositors,
        coalesce(d.total_deposit_amount, 0) as total_deposit_amount,
        coalesce(f.paid_entry_count, 0) as paid_entry_count,
        coalesce(f.free_entry_count, 0) as free_entry_count,
        coalesce(f.gross_entry_revenue, 0) as gross_entry_revenue,
        coalesce(f.cash_entry_revenue, 0) as cash_entry_revenue,
        coalesce(f.credit_entry_revenue, 0) as credit_entry_revenue,
        coalesce(p.total_prize_count, 0) as total_prize_count,
        coalesce(p.credit_prize_count, 0) as credit_prize_count,
        coalesce(p.tangible_prize_count, 0) as tangible_prize_count,
        coalesce(p.main_prize_count, 0) as main_prize_count,
        coalesce(p.second_prize_count, 0) as second_prize_count,
        coalesce(p.gross_prize_value, 0) as gross_prize_value,
        coalesce(p.credit_prize_value, 0) as credit_prize_value,
        coalesce(p.tangible_prize_value, 0) as tangible_prize_value,
        coalesce(p.main_prize_value, 0) as main_prize_value,
        coalesce(p.second_prize_value, 0) as second_prize_value,
        coalesce(f.gross_entry_revenue, 0) - coalesce(p.gross_prize_value, 0) as gross_profit,
        coalesce(f.cash_entry_revenue, 0) - coalesce(p.tangible_prize_value, 0) as cash_profit,
        coalesce(b.deposit_bonuses, 0) as deposit_bonuses,
        coalesce(b.deposit_bonus_value, 0) as deposit_bonus_value,
        coalesce(b.welcome_bonuses, 0) as welcome_bonuses,
        coalesce(b.welcome_bonus_value, 0) as welcome_bonus_value,
        coalesce(b.deposit_matches, 0) as deposit_matches,
        coalesce(b.deposit_match_value, 0) as deposit_match_value,
        coalesce(b.referral_bonuses, 0) as referral_bonuses,
        coalesce(b.referral_bonus_value, 0) as referral_bonus_value,
        coalesce(b.ticket_bonuses, 0) as ticket_bonuses,
        coalesce(b.ticket_bonus_value, 0) as ticket_bonus_value
    from date_tenants as dt
    left join registrations as r
        on dt.date_day = r.date_day
        and dt.tenant_id = r.tenant_id
    left join user_activity as ua
        on dt.date_day = ua.date_day
        and dt.tenant_id = ua.tenant_id
    left join entries as e
        on dt.date_day = e.date_day
        and dt.tenant_id = e.tenant_id
    left join deposits as d
        on dt.date_day = d.date_day
        and dt.tenant_id = d.tenant_id
    left join financials as f
        on dt.date_day = f.date_day
        and dt.tenant_id = f.tenant_id
    left join bonuses as b
        on dt.date_day = b.date_day
        and dt.tenant_id = b.tenant_id
    left join prize_awards as p
        on dt.date_day = p.date_day
        and dt.tenant_id = p.tenant_id

)

select * from joined
