-- One row per site (tenant) per UK month per game per theme per ticket price, across all
-- instances at that price (production instances only). Definitions:
--   new_to_site_players    players whose first-ever site entry was on this row
--   returned_7d_players    of those, players with another entry on the site (any game) within
--                          7 days after their first day; return_7d_rate only counts players
--                          whose 7 days have passed
--   payout_known           ticket credit amount, else the prize's known value

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prizes as (

    select *
    from {{ ref('dim_seven_days__prizes') }}

),

users as (

    select *
    from {{ ref('dim_seven_days__users') }}

),

prod_entries as (

    select
        e.entry_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.user_id,
        e.contest_id,
        e.purchase_id,
        e.entered_at,
        e.entry_date_uk,
        date_trunc('month', e.entry_date_uk)                as activity_month,
        e.entry_fee,
        coalesce(e.won_prize_amount, p.prize_value)         as payout_known,
        c.game_name,
        c.game_theme,
        c.ticket_price
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    left join prizes as p
        on e.prize_id = p.prize_id
    where c.is_prod

),

-- every player's site entry days, for the 7-day return check
player_days as (

    select distinct
        tenant_id,
        user_id,
        entry_date_uk
    from prod_entries

),

returned_7d as (

    select distinct
        u.tenant_id,
        u.user_id
    from users as u
    inner join player_days as d
        on  u.tenant_id = d.tenant_id
        and u.user_id = d.user_id
        and d.entry_date_uk >  u.first_entry_date_uk
        and d.entry_date_uk <= dateadd(day, 7, u.first_entry_date_uk)

),

new_players as (

    select
        u.tenant_id,
        u.user_id,
        u.first_entry_date_uk,
        e.game_name,
        e.game_theme,
        e.ticket_price,
        dateadd(day, 7, u.first_entry_date_uk)
            < cast(convert_timezone('{{ var("local_timezone") }}', current_timestamp()) as date)
                                                            as is_mature_7d,
        r.user_id is not null                               as returned_7d
    from users as u
    inner join prod_entries as e
        on  u.tenant_id = e.tenant_id
        and u.user_id = e.user_id
        and u.first_entered_at = e.entered_at
    left join returned_7d as r
        on  u.tenant_id = r.tenant_id
        and u.user_id = r.user_id
    qualify row_number() over (
        partition by u.tenant_id, u.user_id order by e.entry_id
    ) = 1

),

new_player_metrics as (

    select
        tenant_id,
        date_trunc('month', first_entry_date_uk)            as activity_month,
        game_name,
        game_theme,
        ticket_price,
        count(*)                                            as new_to_site_players,
        count_if(is_mature_7d)                              as mature_new_to_site_players,
        count_if(is_mature_7d and returned_7d)              as returned_7d_players
    from new_players
    group by 1, 2, 3, 4, 5

),

sales as (

    select
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        activity_month,
        game_name,
        game_theme,
        ticket_price,
        count(distinct contest_id)                          as instances,
        count(distinct user_id)                             as players,
        count(*)                                            as entries,
        count(distinct purchase_id)                         as purchases,
        sum(entry_fee)                                      as gross_revenue,
        coalesce(sum(payout_known), 0)                      as payout_known
    from prod_entries
    group by 1, 2, 3, 4, 5, 6, 7, 8

),

final as (

    select
        s.activity_month,
        s.client_id,
        s.tenant_id,
        s.tenant_name,
        s.game_type,
        s.game_name,
        s.game_theme,
        case when s.ticket_price < 1 then 'Low' else 'High' end            as price_tier,
        s.ticket_price,
        s.instances,
        s.players,
        coalesce(n.new_to_site_players, 0)                                  as new_to_site_players,
        coalesce(n.returned_7d_players, 0)                                  as returned_7d_players,
        round(n.returned_7d_players / nullif(n.mature_new_to_site_players, 0), 4)
                                                                            as return_7d_rate,
        s.entries,
        s.purchases,
        s.gross_revenue,
        round(s.gross_revenue / nullif(s.players, 0), 2)                    as revenue_per_player,
        round(s.purchases / nullif(s.players, 0), 2)                        as purchases_per_player,
        round(s.entries / nullif(s.purchases, 0), 2)                        as tickets_per_purchase,
        s.payout_known,
        round(s.payout_known / nullif(s.gross_revenue, 0), 4)               as actual_rtp_known,
        s.gross_revenue - s.payout_known                                    as net_revenue_known
    from sales as s
    left join new_player_metrics as n
        on  s.tenant_id = n.tenant_id
        and s.activity_month = n.activity_month
        and s.game_name = n.game_name
        and equal_null(s.game_theme, n.game_theme)
        and s.ticket_price = n.ticket_price

)

select * from final
