with

deposits as (

    select *
    from {{ ref('fct_prizekings_comps__deposits') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

deposit_metrics as (

    select
        cast(deposits.transaction_created_at as date) as date_day,
        deposits.client_id,
        deposits.tenant_id,
        t.tenant_name,
        deposits.game_type,
        count(*) as total_deposits,
        sum(case when user_deposit_number = 1 then 1 else 0 end) as first_time_depositors,
        sum(amount) as total_deposit_amount
    from deposits
    inner join tenants as t
        on deposits.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

)

select * from deposit_metrics
