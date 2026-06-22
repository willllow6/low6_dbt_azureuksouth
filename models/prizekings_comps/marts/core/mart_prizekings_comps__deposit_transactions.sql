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
        created_at  as transaction_created_at,
        updated_at  as transaction_updated_at,
        row_number() over (partition by user_id order by created_at) as user_deposit_number
    from {{ ref('stg_prizekings_comps__transactions') }}
    where transaction_source = 'wallet_deposit'
    and transaction_direction = 'incoming'
    and balance_type = 'deposit'

),

users as (

    select
        user_id,
        tenant_id,
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
        d.transaction_id,
        d.user_id,
        u.tenant_id,
        d.client_id,
        d.game_type,

        ---------- user
        u.first_name,
        u.last_name,
        u.email,
        u.mobile,

        ---------- tenant
        t.tenant_name,

        ---------- deposit
        d.amount,
        d.transaction_status,
        d.payment_provider,
        d.payment_reference,
        d.user_deposit_number,

        ---------- metadata - simple deposits
        d.meta_data_json:checkoutId::string       as checkout_id,
        d.meta_data_json:currency::string         as currency,

        ---------- metadata - bank/provider deposits
        d.meta_data_json:externalPaymentData:bankName::string        as bank_name,
        d.meta_data_json:externalPaymentData:siteCode::string        as site_code,
        d.meta_data_json:externalPaymentData:statusMessage::string   as provider_status_message,
        d.meta_data_json:externalPaymentData:transactionId::string   as provider_transaction_id,

        ---------- timestamps
        d.payment_processed_at,
        d.transaction_created_at,
        d.transaction_updated_at

    from deposits as d
    left join users as u
        on d.user_id = u.user_id
    left join tenants as t
        on u.tenant_id = t.tenant_id

)

select * from final
