with

entries as (

    select *
    from {{ ref('mart_prizekings_comps__entries') }}

),

entry_metrics as (

    select
        cast(entries.entered_at as date) as date_day,
        entries.client_id,
        entries.tenant_id,
        entries.tenant_name,
        entries.game_type,
        count(distinct entries.contest_sk) as contests_active,
        count(*) as total_entries,
        count(distinct entries.user_id) as unique_entrants,
        sum(case when entries.user_entry_number = 1 then 1 else 0 end) as first_time_entrants
    from entries
    group by 1, 2, 3, 4, 5

)

select * from entry_metrics
