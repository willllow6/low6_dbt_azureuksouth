{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_prizekings_comps__entry_purchases', 'prizekings_share') }}"
) }}

with

entry_purchases as (

    select *
    from {{ ref('mart_prizekings_comps__entry_purchases') }}

)

select
    transaction_id,
    user_id,
    -- tenant_name,
    -- first_name,
    -- last_name,
    -- email,
    -- mobile,
    contest_sk,
    paid_entries,
    free_entries,
    amount,
    currency,
    cash_amount,
    credit_amount,
    transaction_status,
    transaction_created_at
    -- transaction_updated_at
from entry_purchases
