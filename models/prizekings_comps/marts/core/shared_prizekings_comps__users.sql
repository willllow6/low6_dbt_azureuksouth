{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_prizekings_comps__users', 'prizekings_share') }}"
) }}

with

users as (

    select *
    from {{ ref('mart_prizekings_comps__users') }}

)

select
    user_id,
    tenant_name,
    affiliate_name,
    first_name,
    mobile,
    deposit_count,
    total_deposit_amount,
    total_entries,
    deposit_spend,
    credit_spend,
    deposit_balance,
    credit_balance,
    updated_at
from users
