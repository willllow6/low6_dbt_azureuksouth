with

contests as (

    select *
    from {{ ref('dim_prizekings_comps__contests') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

entries as (

    select *
    from {{ ref('fct_prizekings_comps__entries') }}

),

contest_activity as (

    select
        cast(e.entered_at as date) as date_day,
        c.client_id,
        c.tenant_id,
        t.tenant_name,
        c.game_type,
        count(distinct case when c.contest_status = 'scheduled' then c.contest_sk end) as contests_scheduled,
        count(distinct case when c.contest_status = 'active' then c.contest_sk end) as contests_live,
        count(distinct case when c.contest_status = 'completed' then c.contest_sk end) as contests_completed,
        count(*) as total_entries,
        count(distinct c.contest_sk) as contests_with_entries
    from entries as e
    inner join contests as c
        on e.contest_sk = c.contest_sk
    inner join tenants as t
        on c.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

),

final_metrics as (

    select
        date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        contests_scheduled,
        contests_live,
        contests_completed,
        case
            when contests_with_entries > 0
                then total_entries / contests_with_entries
            else 0
        end as avg_entries_per_contest
    from contest_activity

)

select * from final_metrics
