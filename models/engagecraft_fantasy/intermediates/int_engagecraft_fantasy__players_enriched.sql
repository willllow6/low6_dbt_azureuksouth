with

fantasy_players as (

    select *
    from {{ ref('stg_engagecraft_fantasy__fantasy_players') }}

),

players as (

    select *
    from {{ ref('stg_engagecraft_fantasy__players') }}

),

squad_memberships as (

    select *
    from {{ ref('stg_engagecraft_fantasy__squad_memberships') }}
    qualify row_number() over (
        partition by player_id, tournament_id
        order by is_active desc, start_date desc
    ) = 1

),

teams as (

    select *
    from {{ ref('stg_engagecraft_fantasy__teams') }}

),

enriched as (

    select
        fp.fantasy_player_id,
        fp.player_id,
        fp.tournament_id,
        fp.client_id,
        fp.tenant_id,
        fp.tenant_name,
        fp.game_type,
        p.full_name,
        p.first_name,
        p.last_name,
        p.playing_position,
        fp.fantasy_position,
        p.nationality,
        p.nationality_flag_key,
        p.date_of_birth,
        sm.team_id,
        t.team_name,
        t.team_short_name,
        t.tournament_group,
        sm.shirt_number,
        sm.squad_position,
        fp.price,
        fp.ownership_pct,
        fp.availability_display,
        fp.is_visible,
        fp.price_change_up,
        fp.price_change_down,
        fp.created_at,
        fp.updated_at
    from fantasy_players as fp
    left join players as p
        on fp.player_id = p.player_id
    left join squad_memberships as sm
        on fp.player_id = sm.player_id
        and fp.tournament_id = sm.tournament_id
    left join teams as t
        on sm.team_id = t.team_id

)

select * from enriched
