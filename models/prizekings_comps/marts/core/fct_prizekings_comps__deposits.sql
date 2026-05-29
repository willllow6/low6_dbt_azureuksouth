with

deposits as (

    select
        transaction_id,
        user_id,
        client_id,
        game_type,
        transaction_status,
        payment_provider,
        payment_reference,
        amount,
        meta_data_json,
        payment_processed_at,
        created_at as transaction_created_at,
        updated_at as transaction_updated_at
    from {{ ref('stg_prizekings_comps__transactions') }}
    where transaction_source = 'wallet_deposit'
    and transaction_direction = 'incoming'
    and balance_type = 'deposit'
    and transaction_status = 'completed'
    -- and payment_processed_at is not null

),

users as (

    select
        user_id,
        tenant_id
    from {{ ref('dim_prizekings_comps__users') }}

),

joined as (

    select
        d.transaction_id,
        d.user_id,
        u.tenant_id,
        d.client_id,
        d.game_type,
        d.transaction_status,
        d.payment_provider,
        d.payment_reference,
        d.amount,
        d.meta_data_json,
        d.payment_processed_at,
        d.transaction_created_at,
        d.transaction_updated_at
    from deposits as d
    left join users as u
        on d.user_id = u.user_id

),

with_rank as (

    select
        *,
        row_number() over (partition by user_id order by transaction_created_at) as user_deposit_number
    from joined

)

select * from with_rank
