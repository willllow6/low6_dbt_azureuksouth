with

entries as (

    select *
    from {{ ref('fct_tipman_pickem__entries') }}

),

users as (

    select
        user_id,
        username,
        email,
        external_user_id,
        registered_at
    from {{ ref('dim_tipman_pickem__users') }}

),

contests as (

    select
        contest_id,
        tenant_name,
        contest_name,
        contest_status,
        prize_text,
        is_scored,
        opens_at,
        starts_at
    from {{ ref('dim_tipman_pickem__contests') }}

),

joined as (

    select
        entries.entry_id,
        entries.user_id,
        entries.contest_id,
        entries.client_id,
        entries.tenant_id,
        contests.tenant_name,
        entries.game_type,

        entries.total_points,
        entries.tiebreaker_prediction,
        entries.tiebreaker_outcome,
        entries.is_winner,
        entries.entry_number,

        entries.entered_at,
        convert_timezone('UTC', '{{ var("local_timezone") }}', entries.entered_at) as entered_at_local,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entries.entered_at) as date) as entry_date_local,

        users.username,
        users.email,
        users.external_user_id,
        users.registered_at,

        contests.contest_name,
        contests.contest_status,
        contests.prize_text,
        contests.is_scored,
        contests.opens_at as contest_opens_at,
        contests.starts_at as contest_starts_at

    from entries
    left join users
        on entries.user_id = users.user_id
    left join contests
        on entries.contest_id = contests.contest_id

)

select * from joined
