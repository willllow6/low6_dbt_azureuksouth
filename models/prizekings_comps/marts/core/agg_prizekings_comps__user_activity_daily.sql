with

entries as (

    select *
    from {{ ref('fct_prizekings_comps__competition_entries') }}

),

competitions as (

    select *
    from {{ ref('dim_prizekings_comps__competitions') }}

),

entry_metrics as (

    select
        cast(entries.created_at as date) as activity_date,
        competitions.tenant_id,
        count(distinct user_id) as active_players
    from entries
    inner join competitions
        on entries.competition_sk = competitions.competition_sk
    group by 1,2

)

select * from entry_metrics
