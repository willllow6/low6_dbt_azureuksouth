{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_prizekings_comps__deposit_transactions', 'prizekings_share') }}"
) }}

with

deposit_transactions as (

    select *
    from {{ ref('mart_prizekings_comps__deposit_transactions') }}

)

select
    transaction_id,
    user_id,
    tenant_name,
    first_name,
    last_name,
    email,
    mobile,
    amount,
    currency,
    transaction_status,
    payment_provider,
    payment_reference,
    checkout_id,
    bank_name,
    site_code,
    provider_transaction_id,
    provider_status_message,
    -- user_deposit_number,
    payment_processed_at_local,
    transaction_created_at,
    transaction_updated_at
from deposit_transactions
