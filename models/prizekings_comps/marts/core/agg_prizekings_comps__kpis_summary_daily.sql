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

actives as (

    select
        cast(e.entered_at as date) as date_day,
        e.tenant_id,
        count(distinct e.user_id) as daily_actives
    from {{ ref('fct_prizekings_comps__entries') }} as e
    group by 1, 2

),

joined as (

    select
        dt.date_day,
        'prizekings' as client_id,
        dt.tenant_id,
        dt.tenant_name,
        'prize_competition' as game_type,
        coalesce(r.registrations, 0) as registrations,
        coalesce(d.first_time_deposits, 0) as first_time_deposits,
        case
            when coalesce(r.registrations, 0) > 0
                then round(coalesce(d.first_time_deposits, 0) / r.registrations, 4)
            else 0
        end as reg_to_ftd,
        coalesce(d.total_deposits, 0) as total_deposits,
        coalesce(d.total_deposit_amount, 0) as total_deposit_amount,
        case
            when coalesce(d.total_deposits, 0) > 0
                then round(d.total_deposit_amount / d.total_deposits, 2)
            else 0
        end as avg_deposit_value,
        coalesce(ef.gross_entry_revenue, 0) as gross_entry_revenue,
        coalesce(ef.cash_entry_revenue, 0) as cash_entry_revenue,
        coalesce(a.daily_actives, 0) as daily_actives,
        case
            when coalesce(a.daily_actives, 0) > 0
                then round(coalesce(ef.cash_entry_revenue, 0) / a.daily_actives, 2)
            else 0
        end as daily_arpu
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
    left join actives as a
        on dt.date_day = a.date_day
        and dt.tenant_id = a.tenant_id

)

select * from joined
