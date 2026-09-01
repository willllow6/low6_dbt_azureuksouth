with

entry_purchases as (

    select *
    from {{ ref('fct_prizekings_comps__entry_purchases') }}

),

users as (

    select
        user_id,
        first_name,
        last_name,
        email,
        mobile
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('dim_prizekings_comps__tenants') }}

),

final as (

    select

        ---------- ids
        p.transaction_id,
        p.user_id,
        p.tenant_id,
        p.client_id,
        p.game_type,
        p.contest_sk,

        ---------- user
        u.first_name,
        u.last_name,
        u.email,
        u.mobile,

        ---------- tenant
        t.tenant_name,

        ---------- entry purchase
        p.paid_entries,
        p.free_entries,
        p.amount,
        p.currency,
        case when p.balance_type = 'deposit' then p.amount else 0 end as cash_amount,
        case when p.balance_type = 'site_credit' then p.amount else 0 end as credit_amount,
        p.transaction_status,

        ---------- timestamps
        p.transaction_created_at,
        p.transaction_updated_at

    from entry_purchases as p
    left join users as u
        on p.user_id = u.user_id
    left join tenants as t
        on p.tenant_id = t.tenant_id

)

select * from final
