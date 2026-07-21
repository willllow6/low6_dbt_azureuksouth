with

gameweeks as (

    select *
    from {{ ref('stg_engagecraft_fantasy__gameweeks') }}

),

tournaments as (

    select
        tournament_id,
        tournament_name
    from {{ ref('stg_engagecraft_fantasy__tournaments') }}

),

joined as (

    select
        g.gameweek_id,
        g.tournament_id,
        t.tournament_name,
        g.finalised_by_admin_user_id,
        g.client_id,
        g.tenant_id,
        g.tenant_name,
        g.game_type,
        g.gameweek_number,
        g.gameweek_name,
        g.gameweek_status,
        g.knockout_round,
        g.is_active,
        g.is_double_gameweek,
        g.budget_initial,
        g.starts_at,
        g.ends_at,
        g.deadline_at,
        g.finalised_at,
        g.deleted_at,
        g.created_at,
        g.updated_at
    from gameweeks as g
    left join tournaments as t
        on g.tournament_id = t.tournament_id

)

select * from joined
