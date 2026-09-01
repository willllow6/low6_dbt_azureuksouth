with

kpis as (

    select *
    from {{ ref('agg_prizekings_comps__kpis_summary_daily') }}

)

select
    date_day,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
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
