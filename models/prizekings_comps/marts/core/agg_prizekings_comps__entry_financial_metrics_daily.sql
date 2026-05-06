with

transactions as (

    select *
    from {{ ref('stg_prizekings_comps__transactions') }}
    where contest_sk is not null

),

contests as (

    select *
    from {{ ref('dim_prizekings_comps__contests') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

base as (

    select
        cast(transactions.created_at as date) as date_day,
        transactions.client_id,
        contests.tenant_id,
        t.tenant_name,
        transactions.game_type,
        sum(transactions.entries) as entry_count,
        sum(transactions.paid_entries) as paid_entry_count,
        sum(transactions.free_entries) as free_entry_count,
        sum(case when transactions.transaction_direction = 'outgoing' then transactions.amount else 0 end) as gross_entry_revenue,
        sum(case when transactions.transaction_direction = 'outgoing' and transactions.balance_type = 'deposit' then transactions.amount else 0 end) as cash_entry_revenue,
        sum(case when transactions.transaction_direction = 'outgoing' and transactions.balance_type = 'site_credit' then transactions.amount else 0 end) as credit_entry_revenue
    from transactions
    left join contests
        on transactions.contest_sk = contests.contest_sk
    inner join tenants as t
        on contests.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

)

select * from base
