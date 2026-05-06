with

transactions as (

    select *
    from {{ ref('stg_prizekings_comps__transactions') }}
    where contest_sk is not null

),

contests as (

    select
        contest_sk,
        tenant_id,
        client_id,
        game_type
    from {{ ref('int_prizekings_comps__contests_unioned') }}

),

base as (

    select
        t.contest_sk,
        c.tenant_id,
        c.client_id,
        c.game_type,
        sum(t.entries) as entry_count,
        sum(t.paid_entries) as paid_entry_count,
        sum(t.free_entries) as free_entry_count,
        sum(case when t.transaction_direction = 'outgoing' then t.amount else 0 end) as gross_entry_revenue,
        sum(case when t.transaction_direction = 'outgoing' and t.balance_type = 'deposit' then t.amount else 0 end) as cash_entry_revenue,
        sum(case when t.transaction_direction = 'outgoing' and t.balance_type = 'site_credit' then t.amount else 0 end) as credit_entry_revenue,
        sum(case when t.transaction_direction = 'incoming' and t.balance_type = 'site_credit' then 1 else 0 end) as credit_prize_count,
        sum(case when t.transaction_direction = 'incoming' and t.balance_type = 'site_credit' then t.amount else 0 end) as credit_prize_value
    from transactions as t
    inner join contests as c
        on t.contest_sk = c.contest_sk
    group by 1, 2, 3, 4

)

select * from base
