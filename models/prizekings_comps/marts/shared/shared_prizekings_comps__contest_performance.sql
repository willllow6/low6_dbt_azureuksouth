{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_prizekings_comps__contest_performance', 'prizekings_share') }}"
) }}


with

contest_performance as (

    select *
    from {{ ref('agg_prizekings_comps__contest_performance') }}

)

select
    contest_sk,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    contest_name,
    contest_type,
    contest_status,
    entry_fee,
    starts_at,
    ends_at,
    total_entry_count,
    paid_entry_count,
    free_entry_count,
    gross_entry_revenue,
    cash_entry_revenue,
    gross_prize_value as prizes,
    gross_profit as net_revenue
    -- updated_at
from contest_performance
