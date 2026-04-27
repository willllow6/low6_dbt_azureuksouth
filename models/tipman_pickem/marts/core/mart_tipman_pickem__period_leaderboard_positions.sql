with

period_leaderboards as (

    select *
    from {{ ref('stg_tipman_pickem__period_leaderboards') }}

),

tenants as (

    select
        tenant_id,
        tenant_code,
        tenant_name
    from {{ ref('dim_tipman_pickem__tenants') }}

),

users as (

    select
        user_id,
        username,
        email,
        external_user_id
    from {{ ref('dim_tipman_pickem__users') }}

),

joined as (

    select
        period_leaderboards.period_leaderboard_id,
        period_leaderboards.user_id,
        period_leaderboards.client_id,
        tenants.tenant_id,
        tenants.tenant_name,
        period_leaderboards.game_type,

        users.username,
        users.email,
        users.external_user_id,

        period_leaderboards.period_type,
        period_leaderboards.period_start,
        period_leaderboards.period_end,
        period_leaderboards.contest_data,
        period_leaderboards.total_points,
        period_leaderboards.leaderboard_position,

        dense_rank() over (
            partition by
                tenants.tenant_id,
                period_leaderboards.period_type,
                period_leaderboards.period_start
            order by period_leaderboards.total_points desc
        ) as leaderboard_rank,

        period_leaderboards.created_at,
        period_leaderboards.updated_at

    from period_leaderboards
    left join tenants
        on period_leaderboards.tenant_code = tenants.tenant_code
    left join users
        on period_leaderboards.user_id = users.user_id

)

select * from joined
