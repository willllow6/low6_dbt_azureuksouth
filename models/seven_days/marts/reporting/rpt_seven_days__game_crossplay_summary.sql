-- One row per site (tenant) per game per other game (production instances only, games by
-- game_name across themes and prices). Of the players of game_name, how many also played
-- other_game_name and which they played first. game_name = other_game_name rows give the
-- game's total players. Distinct games per player is games_played on dim_seven_days__users.

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

user_games as (

    select
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        c.game_name,
        min(e.entered_at)                                   as first_entered_at,
        sum(e.entry_fee)                                    as spend
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod
    group by 1, 2, 3, 4, 5, 6

),

pairs as (

    select
        a.client_id,
        a.tenant_id,
        a.tenant_name,
        a.game_type,
        a.game_name,
        b.game_name                                         as other_game_name,
        count(*)                                            as players_both,
        count_if(a.first_entered_at < b.first_entered_at)   as players_game_first,
        count_if(a.first_entered_at > b.first_entered_at)   as players_other_game_first,
        sum(a.spend)                                        as game_spend,
        sum(b.spend)                                        as other_game_spend
    from user_games as a
    inner join user_games as b
        on  a.tenant_id = b.tenant_id
        and a.user_id = b.user_id
    group by 1, 2, 3, 4, 5, 6

),

final as (

    select
        p.client_id,
        p.tenant_id,
        p.tenant_name,
        p.game_type,
        p.game_name,
        p.other_game_name,
        t.players_both                                      as game_players,
        p.players_both,
        round(p.players_both / nullif(t.players_both, 0), 4) as share_also_played,
        p.players_game_first,
        p.players_other_game_first,
        p.game_spend,
        p.other_game_spend
    from pairs as p
    inner join pairs as t
        on  p.tenant_id = t.tenant_id
        and p.game_name = t.game_name
        and t.other_game_name = t.game_name

)

select * from final
