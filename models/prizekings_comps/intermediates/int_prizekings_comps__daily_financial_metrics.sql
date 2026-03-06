with

transactions as (

    select *
    from {{ ref('stg_prizekings_comps__transactions') }}
    where competition_sk is not null

),

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

base as (

    select 
        cast(transactions.created_at as date) as transaction_date,
        users.tenant_id,
        sum(case when transaction_direction = 'outgoing' then amount else 0 end) as gross_entry_revenue,
        sum(case when transaction_direction = 'outgoing' and balance_type = 'deposit' then amount else 0 end) as cash_entry_revenue,
        sum(case when transaction_direction = 'outgoing' and balance_type = 'site_credit' then amount else 0 end) as credit_entry_spend,
        sum(case when transaction_direction = 'incoming' then amount else 0 end) as total_prize_value_awarded,
        sum(case when transaction_direction = 'incoming' and balance_type = 'deposit' then amount else 0 end) as cash_prize_value_awarded,
        sum(case when transaction_direction = 'incoming' and balance_type = 'site_credit' then amount else 0 end) as credit_prize_value_awarded
    from transactions 
    left join users 
        on transactions.user_id = users.user_id
    group by 1,2

)

select
    *,
    cash_entry_revenue - cash_prize_value_awarded as gross_profit
from base