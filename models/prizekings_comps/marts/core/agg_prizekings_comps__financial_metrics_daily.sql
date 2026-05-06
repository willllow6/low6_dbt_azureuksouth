with

entry_financials as (

    select *
    from {{ ref('agg_prizekings_comps__entry_financial_metrics_daily') }}

),

prize_awards as (

    select *
    from {{ ref('agg_prizekings_comps__prize_awards_daily') }}

),

joined as (

    select
        coalesce(ef.date_day, pa.date_day) as date_day,
        coalesce(ef.client_id, pa.client_id) as client_id,
        coalesce(ef.tenant_id, pa.tenant_id) as tenant_id,
        coalesce(ef.tenant_name, pa.tenant_name) as tenant_name,
        coalesce(ef.game_type, pa.game_type) as game_type,
        'GBP' as currency,
        coalesce(ef.gross_entry_revenue, 0) as gross_revenue,
        coalesce(pa.gross_prize_value, 0) as gross_prizes,
        coalesce(ef.gross_entry_revenue, 0) - coalesce(pa.gross_prize_value, 0) as gross_profit
    from entry_financials as ef
    full outer join prize_awards as pa
        on ef.date_day = pa.date_day
        and ef.tenant_id = pa.tenant_id

)

select * from joined
