{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_prizekings_comps__kpis_cumulative_daily', 'prizekings_share') }}"
) }}

with

kpis_cumulative as (

    select *
    from {{ ref('mart_prizekings_comps__kpis_cumulative_daily') }}

)

select
    date_day,
    tenant_name,
    cumulative_registrations,
    cumulative_first_time_deposits,
    reg_to_ftd,
    cumulative_total_deposits,
    cumulative_total_deposit_amount,
    avg_deposit_value,
    cumulative_gross_entry_revenue,
    cumulative_cash_entry_revenue
from kpis_cumulative
