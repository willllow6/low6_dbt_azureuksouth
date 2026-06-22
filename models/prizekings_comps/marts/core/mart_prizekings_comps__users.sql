with

users as (

    select
        user_id,
        client_id,
        tenant_id,
        game_type,
        first_name,
        last_name,
        mobile,
        email,
        is_active,
        created_at,
        updated_at
    from {{ ref('dim_prizekings_comps__users') }}

),

deposits as (

    select
        user_id,
        count(transaction_id)   as deposit_count,
        sum(amount)             as total_deposit_amount
    from {{ ref('fct_prizekings_comps__deposits') }}
    group by user_id

),

entries as (

    select
        user_id,
        count(entry_sk) as total_entries
    from {{ ref('fct_prizekings_comps__entries') }}
    group by user_id

),

entry_spend as (

    select
        user_id,
        sum(case when balance_type = 'deposit'     then amount else 0 end) as deposit_spend,
        sum(case when balance_type = 'site_credit' then amount else 0 end) as credit_spend
    from {{ ref('stg_prizekings_comps__transactions') }}
    where transaction_source in (
        'ticket_purchase_balance',
        'spot_the_ball_entry_balance',
        'arcade_entry_balance'
    )
    and transaction_direction = 'outgoing'
    and transaction_status = 'completed'
    group by user_id

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('dim_prizekings_comps__tenants') }}

),

user_balances as (

    select
        user_id,
        sum(case
            when balance_type = 'deposit' and transaction_direction = 'incoming' then amount
            when balance_type = 'deposit' and transaction_direction = 'outgoing' then -amount
            else 0
        end) as deposit_balance,
        sum(case
            when balance_type = 'site_credit' and transaction_direction = 'incoming' then amount
            when balance_type = 'site_credit' and transaction_direction = 'outgoing' then -amount
            else 0
        end) as credit_balance
    from {{ ref('stg_prizekings_comps__transactions') }}
    where transaction_status = 'completed'
    group by user_id

),

final as (

    select
        u.user_id,
        u.client_id,
        u.tenant_id,
        u.game_type,
        u.first_name,
        u.last_name,
        u.mobile,
        u.email,
        t.tenant_name,
        coalesce(d.deposit_count, 0)        as deposit_count,
        coalesce(d.total_deposit_amount, 0) as total_deposit_amount,
        coalesce(e.total_entries, 0)        as total_entries,
        coalesce(s.deposit_spend, 0)        as deposit_spend,
        coalesce(s.credit_spend, 0)         as credit_spend,
        coalesce(b.deposit_balance, 0)      as deposit_balance,
        coalesce(b.credit_balance, 0)       as credit_balance,
        u.is_active,
        u.created_at,
        u.updated_at
    from users as u
    left join deposits as d
        on u.user_id = d.user_id
    left join entries as e
        on u.user_id = e.user_id
    left join entry_spend as s
        on u.user_id = s.user_id
    left join user_balances as b
        on u.user_id = b.user_id
    left join tenants as t
        on u.tenant_id = t.tenant_id

)

select * from final
