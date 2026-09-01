with

kpis_cumulative as (

    select *
    from {{ ref('agg_prizekings_comps__kpis_summary_cumulative_daily') }}

)

select
    date_day,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    cumulative_registrations,
    cumulative_first_time_deposits,
    reg_to_ftd,
    cumulative_total_deposits,
    cumulative_total_deposit_amount,
    avg_deposit_value,
    cumulative_gross_entry_revenue,
    cumulative_cash_entry_revenue
from kpis_cumulative
