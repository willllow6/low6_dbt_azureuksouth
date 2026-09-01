{{ config(
    materialized='view',
    secure=true,
    post_hook="{{ share_view('analytics_prizekings_comps', 'shared_prizekings_comps__kpis_daily', 'prizekings_share') }}"
) }}

with

kpis as (

    select *
    from {{ ref('mart_prizekings_comps__kpis_daily') }}

)

select
    date_day,
    tenant_name,
    registrations,
    first_time_deposits,
    reg_to_ftd,
    total_deposits,
    total_deposit_amount,
    avg_deposit_value,
    gross_entry_revenue,
    cash_entry_revenue,
    daily_actives,
    daily_arpu
from kpis
