{{ config(materialized='view') }}

-- Unions the live game metrics table with any archive in ANALYTICS_ARCHIVE.
-- No archive table currently exists for this Azure UK South project (verified against
-- information_schema.databases), so this is a passthrough view of the live table. Add an
-- `archive as (...)` CTE here (null-padding missing columns, aliasing legacy names) if/when
-- an archive table is added, per the low6_reporting union pattern.

with

live as (

    select *
    from {{ ref('agg_low6__game_metrics_daily') }}

)

select * from live
