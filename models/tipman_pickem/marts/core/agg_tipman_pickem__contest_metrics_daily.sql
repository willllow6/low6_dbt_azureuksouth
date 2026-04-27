-- Uses contest starts_at date as the reference date for daily aggregation.
-- TODO: confirm exact contest_status values with tipman source team.
with

contests as (

    select
        contest_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        contest_status,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', starts_at) as date) as contest_date
    from {{ ref('dim_tipman_pickem__contests') }}

),

entries as (

    select
        contest_id,
        count(entry_id) as entry_count
    from {{ ref('fct_tipman_pickem__entries') }}
    group by contest_id

),

daily as (

    select
        contests.contest_date as date_day,
        contests.client_id,
        contests.tenant_id,
        contests.tenant_name,
        contests.game_type,
        count(distinct case
            when contests.contest_status in ('DRAFT', 'OPEN')
            then contests.contest_id
        end) as contests_scheduled,
        count(distinct case
            when contests.contest_status in ('LIVE', 'SCORING')
            then contests.contest_id
        end) as contests_live,
        count(distinct case
            when contests.contest_status in ('COMPLETED', 'CLOSED')
            then contests.contest_id
        end) as contests_completed,
        avg(coalesce(entries.entry_count, 0)) as avg_entries_per_contest
    from contests
    left join entries
        on contests.contest_id = entries.contest_id
    group by
        contests.contest_date,
        contests.client_id,
        contests.tenant_id,
        contests.tenant_name,
        contests.game_type

)

select * from daily
