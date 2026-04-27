with

contest_leaderboards as (

    select *
    from {{ ref('stg_tipman_pickem__contest_leaderboards') }}

),

entries as (

    select *
    from {{ ref('mart_tipman_pickem__entries') }}

),

joined as (

    select
        contest_leaderboards.contest_leaderboard_id,
        contest_leaderboards.user_id,
        contest_leaderboards.contest_id,
        contest_leaderboards.client_id,
        entries.tenant_id,
        entries.tenant_name,
        contest_leaderboards.game_type,

        entries.username,
        entries.email,
        entries.external_user_id,

        entries.contest_name,
        entries.contest_status,
        entries.contest_starts_at,
        entries.entered_at,
        entries.entered_at_local,
        entries.tiebreaker_prediction,
        entries.tiebreaker_outcome,
        contest_leaderboards.tiebreaker_margin,

        contest_leaderboards.points,
        contest_leaderboards.leaderboard_position,

        dense_rank() over (
            partition by contest_leaderboards.contest_id
            order by contest_leaderboards.points desc, contest_leaderboards.tiebreaker_margin asc
        ) as leaderboard_rank,

        contest_leaderboards.created_at,
        contest_leaderboards.updated_at

    from contest_leaderboards
    left join entries
        on contest_leaderboards.user_id = entries.user_id
        and contest_leaderboards.contest_id = entries.contest_id

)

select * from joined
