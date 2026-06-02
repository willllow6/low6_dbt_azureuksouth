with

applied_transfers as (

    select
        transfer_id,
        fantasy_team_id,
        target_matchday_id,
        player_in_id,
        player_out_id
    from {{ ref('fct_engagecraft_fantasy__transfers') }}
    where transfer_status = 'applied'

),

transfers_in as (

    select
        target_matchday_id as matchday_id,
        player_in_id as fantasy_player_id,
        count(*) as transfers_in
    from applied_transfers
    group by 1, 2

),

transfers_out as (

    select
        target_matchday_id as matchday_id,
        player_out_id as fantasy_player_id,
        count(*) as transfers_out
    from applied_transfers
    group by 1, 2

),

combined as (

    select
        coalesce(ti.matchday_id, t_out.matchday_id) as matchday_id,
        coalesce(ti.fantasy_player_id, t_out.fantasy_player_id) as fantasy_player_id,
        coalesce(ti.transfers_in, 0) as transfers_in,
        coalesce(t_out.transfers_out, 0) as transfers_out
    from transfers_in as ti
    full outer join transfers_out as t_out
        on ti.matchday_id = t_out.matchday_id
        and ti.fantasy_player_id = t_out.fantasy_player_id

),

players as (

    select
        fantasy_player_id,
        full_name,
        fantasy_position,
        team_name,
        client_id,
        tenant_id,
        tenant_name,
        game_type
    from {{ ref('dim_engagecraft_fantasy__players') }}

),

matchdays as (

    select
        matchday_id,
        matchday_number,
        matchday_name,
        starts_at
    from {{ ref('dim_engagecraft_fantasy__matchdays') }}

),

enriched as (

    select
        c.matchday_id,
        m.matchday_number,
        m.matchday_name,
        m.starts_at,
        c.fantasy_player_id,
        p.full_name,
        p.fantasy_position,
        p.team_name,
        p.client_id,
        p.tenant_id,
        p.tenant_name,
        p.game_type,
        c.transfers_in,
        c.transfers_out,
        c.transfers_in - c.transfers_out as net_transfers
    from combined as c
    left join players as p
        on c.fantasy_player_id = p.fantasy_player_id
    left join matchdays as m
        on c.matchday_id = m.matchday_id

)

select * from enriched
