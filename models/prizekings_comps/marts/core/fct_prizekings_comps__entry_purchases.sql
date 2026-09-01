with

transactions as (

    select
        transaction_id,
        user_id,
        client_id,
        game_type,
        contest_sk,
        balance_type,
        transaction_status,
        payment_provider,
        paid_entries,
        free_entries,
        amount,
        created_at as transaction_created_at,
        updated_at as transaction_updated_at
    from {{ ref('stg_prizekings_comps__transactions') }}
    where contest_sk is not null
    and transaction_direction = 'outgoing'

),

contests as (

    select
        contest_sk,
        tenant_id
    from {{ ref('int_prizekings_comps__contests_unioned') }}

),

tenants as (

    select
        tenant_id,
        tenant_name
    from {{ ref('dim_prizekings_comps__tenants') }}

),

final as (

    select
        t.transaction_id,
        t.user_id,
        c.tenant_id,
        t.client_id,
        t.game_type,
        t.contest_sk,
        t.balance_type,
        t.transaction_status,
        case
            when t.payment_provider = 'mesh' then 'USDC'
            when tn.tenant_name = 'South Africa' then 'ZAR'
            else 'GBP'
        end as currency,
        t.paid_entries,
        t.free_entries,
        t.amount,
        t.transaction_created_at,
        t.transaction_updated_at
    from transactions as t
    inner join contests as c
        on t.contest_sk = c.contest_sk
    left join tenants as tn
        on c.tenant_id = tn.tenant_id

)

select * from final
