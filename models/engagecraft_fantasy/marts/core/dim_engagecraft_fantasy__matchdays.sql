with

matchdays as (

    select *
    from {{ ref('stg_engagecraft_fantasy__matchdays') }}

),

tournaments as (

    select
        tournament_id,
        tournament_name
    from {{ ref('stg_engagecraft_fantasy__tournaments') }}

),

joined as (

    select
        m.matchday_id,
        m.tournament_id,
        t.tournament_name,
        m.client_id,
        m.tenant_id,
        m.tenant_name,
        m.game_type,
        m.matchday_number,
        m.matchday_name,
        m.matchday_status,
        m.is_active,
        m.expected_match_count,
        m.budget_initial,
        m.starts_at,
        m.ends_at,
        m.locks_at,
        m.deleted_at,
        m.created_at,
        m.updated_at
    from matchdays as m
    left join tournaments as t
        on m.tournament_id = t.tournament_id

)

select * from joined
