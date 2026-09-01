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
    created_at,
    updated_at,
    is_active_user,
    is_daily_active_user,
    is_monthly_active_user,
    is_yearly_active_user
from users
