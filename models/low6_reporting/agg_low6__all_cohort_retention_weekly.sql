{{ config(materialized='view') }}

-- Unions the live cohort retention table with any archive in ANALYTICS_ARCHIVE.
-- No archive table currently exists for this Azure UK South project (verified against
-- information_schema.databases), so this is a passthrough view of the live table. Add an
-- `archive as (...)` CTE here (first_entry_week -> cohort_week, entry_week -> activity_week,
-- weeks_from_first_entry -> weeks_since_cohort, active_users -> retained_users) if/when an
-- archive table is added, per the low6_reporting union pattern.

with

live as (

    select *
    from {{ ref('agg_low6__cohort_retention_weekly') }}

)

select * from live
