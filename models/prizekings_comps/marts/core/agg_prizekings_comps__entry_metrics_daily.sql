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
        cast(entries.created_at as date) as entry_date,
        competitions.tenant_id,
        count(*) as total_entries,
        sum(case when user_entry_number = 1 then 1 else 0 end) as first_user_entries,
        sum(case when entries.is_winner then 1 else 0 end ) as total_winning_entries
    from entries
    inner join competitions
        on entries.competition_sk = competitions.competition_sk
    group by 1,2

)

select * from entry_metrics
