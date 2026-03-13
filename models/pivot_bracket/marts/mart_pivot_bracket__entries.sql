with

entries as (

    select *
    from {{ ref('fct_pivot_bracket__entries') }}

),

users as (

    select *
    from {{ ref('dim_pivot_bracket__users') }}

),

contests as (

    select *
    from {{ ref('dim_pivot_bracket__contests') }}

),

joined as (

    select
        entries.entry_id,
        entries.user_id,
        entries.contest_id,

        entries.points,
        entries.tiebreaker_selection,
        entries.entry_date,
        entries.entry_date_et,
        entries.entered_at,
        entries.entered_at_et,

        users.email,
        users.username,

        contests.contest_name,
        contests.contest_description,
        contests.contest_status,
        contests.contest_type,
        contests.contest_opens_at,
        contests.contest_opens_at_et,
        contests.contest_closes_at,
        contests.contest_closes_at_et,
        contests.contest_starts_at,
        contests.contest_starts_at_et,
        contests.contest_ends_at,
        contests.contest_ends_at_et,

        contests.customer_name,

        contests.tournament_name,
        contests.tournament_description,
        contests.tournament_status

    from entries
    left join users 
        on entries.user_id = users.user_id
    left join contests
        on entries.contest_id = contests.contest_id
        

)

select * from joined