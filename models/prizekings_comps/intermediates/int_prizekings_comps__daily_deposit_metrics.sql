with

deposits as (

    select *
    from {{ ref('fct_prizekings_comps__deposits') }}

),

users as (

    select *
    from {{ ref('dim_prizekings_comps__users') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}
    
),

deposit_metrics as (

    select
        cast(deposits.payment_processed_at as date) as deposit_date,
        tenants.tenant_name,
        count(*) as total_deposits,
        sum(case when user_deposit_number = 1 then 1 else 0 end) as first_time_depositors,
        sum(amount) as total_deposit_amount
    from deposits
    inner join users
        on deposits.user_id = users.user_id
    inner join tenants
        on users.tenant_id = tenants.tenant_id
    group by 1,2

)

select * from deposit_metrics
