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

date_tenants as (

    select
        date_day,
        tenant_id,
        tenant_name
    from date_generator
    join tenants

),

registrations as (

    select
        cast(u.created_at as date) as date_day,
        u.tenant_id,
        count(*) as registrations
    from {{ ref('dim_prizekings_comps__users') }} as u
    group by 1, 2

),

deposits as (

    select
        cast(d.transaction_created_at as date) as date_day,
        d.tenant_id,
        count(*) as total_deposits,
        sum(case when d.user_deposit_number = 1 then 1 else 0 end) as first_time_deposits,
        sum(d.amount) as total_deposit_amount
    from {{ ref('fct_prizekings_comps__deposits') }} as d
    group by 1, 2

),

entry_financials as (

    select
        cast(p.transaction_created_at as date) as date_day,
        p.tenant_id,
        sum(p.amount) as gross_entry_revenue,
        sum(case when p.balance_type = 'deposit' then p.amount else 0 end) as cash_entry_revenue
    from {{ ref('fct_prizekings_comps__entry_purchases') }} as p
    group by 1, 2

),

daily as (

    select
        dt.date_day,
        'prizekings' as client_id,
        dt.tenant_id,
        dt.tenant_name,
        'prize_competition' as game_type,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.first_time_deposits, 0) as first_time_deposits,
        coalesce(d.total_deposits, 0) as total_deposits,
        coalesce(d.total_deposit_amount, 0) as total_deposit_amount,
        coalesce(ef.gross_entry_revenue, 0) as gross_entry_revenue,
        coalesce(ef.cash_entry_revenue, 0) as cash_entry_revenue
    from date_tenants as dt
    left join registrations as r
        on dt.date_day = r.date_day
        and dt.tenant_id = r.tenant_id
    left join deposits as d
        on dt.date_day = d.date_day
        and dt.tenant_id = d.tenant_id
    left join entry_financials as ef
        on dt.date_day = ef.date_day
        and dt.tenant_id = ef.tenant_id

),

cumulative as (

    select
        date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        sum(registrations) over (
            partition by tenant_id order by date_day
            rows between unbounded preceding and current row
        ) as cumulative_registrations,
        sum(first_time_deposits) over (
            partition by tenant_id order by date_day
            rows between unbounded preceding and current row
        ) as cumulative_first_time_deposits,
        sum(total_deposits) over (
            partition by tenant_id order by date_day
            rows between unbounded preceding and current row
        ) as cumulative_total_deposits,
        sum(total_deposit_amount) over (
            partition by tenant_id order by date_day
            rows between unbounded preceding and current row
        ) as cumulative_total_deposit_amount,
        sum(gross_entry_revenue) over (
            partition by tenant_id order by date_day
            rows between unbounded preceding and current row
        ) as cumulative_gross_entry_revenue,
        sum(cash_entry_revenue) over (
            partition by tenant_id order by date_day
            rows between unbounded preceding and current row
        ) as cumulative_cash_entry_revenue
    from daily

),

final as (

    select
        date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        cumulative_registrations,
        cumulative_first_time_deposits,
        case
            when cumulative_registrations > 0
                then round(cumulative_first_time_deposits / cumulative_registrations, 4)
            else 0
        end as reg_to_ftd,
        cumulative_total_deposits,
        cumulative_total_deposit_amount,
        case
            when cumulative_total_deposits > 0
                then round(cumulative_total_deposit_amount / cumulative_total_deposits, 2)
            else 0
        end as avg_deposit_value,
        cumulative_gross_entry_revenue,
        cumulative_cash_entry_revenue
    from cumulative

)

select * from final
