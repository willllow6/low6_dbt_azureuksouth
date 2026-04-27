with

contests as (

    select *
    from {{ ref('dim_tipman_pickem__contests') }}

),

entries as (

    select
        contest_id,
        count(entry_id) as total_entries,
        count(distinct user_id) as unique_entrants,
        count(case when entry_number = 1 then entry_id end) as first_entries,
        count(case when entry_number > 1 then entry_id end) as returning_entries,
        round(avg(total_points), 2) as avg_points,
        max(total_points) as max_points,
        min(entered_at) as first_entry_at,
        max(entered_at) as last_entry_at
    from {{ ref('fct_tipman_pickem__entries') }}
    group by contest_id

),

selections as (

    select
        contest_id,
        count(selection_id) as total_selections,
        count(case when option_id is not null then selection_id end) as answered_selections
    from {{ ref('stg_tipman_pickem__selections') }}
    group by contest_id

),

questions as (

    select
        contest_id,
        count(question_id) as total_questions
    from {{ ref('stg_tipman_pickem__questions') }}
    where question_type != 'tiebreaker'
    group by contest_id

),

joined as (

    select
        contests.contest_id,
        contests.client_id,
        contests.tenant_id,
        contests.tenant_name,
        contests.game_type,

        contests.contest_name,
        contests.contest_status,
        contests.is_active,
        contests.is_scored,
        contests.prize_text,
        contests.opens_at,
        contests.starts_at,

        coalesce(questions.total_questions, 0) as total_questions,
        coalesce(entries.total_entries, 0) as total_entries,
        coalesce(entries.unique_entrants, 0) as unique_entrants,
        coalesce(entries.first_entries, 0) as first_entries,
        coalesce(entries.returning_entries, 0) as returning_entries,
        coalesce(entries.avg_points, 0) as avg_points,
        coalesce(entries.max_points, 0) as max_points,
        coalesce(selections.total_selections, 0) as total_selections,

        entries.first_entry_at,
        entries.last_entry_at

    from contests
    left join entries
        on contests.contest_id = entries.contest_id
    left join selections
        on contests.contest_id = selections.contest_id
    left join questions
        on contests.contest_id = questions.contest_id

)

select * from joined
