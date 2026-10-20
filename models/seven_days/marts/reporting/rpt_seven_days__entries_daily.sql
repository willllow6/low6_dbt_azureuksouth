-- One row per UK day × tenant × game × theme × ticket price (production instances only).
-- Replaces legacy agg_seven_days__entries_daily. Definitions:
--   price_tier          'Low' (ticket_price < 1) / 'High' (ticket_price >= 1)
--   new_to_site_*       the player's first-ever entry / purchase on the site (tenant), so
--                       entries and purchases each equal new players; revenue is that first
--                       purchase's value
--   new_to_game_*       as new_to_site_*, for the player's first entry / purchase of this game
--                       (game_name, any theme / price) on the site
--   gross_revenue       entries × ticket price

with

entries as (

    select *
    from {{ ref('fct_seven_days__entries') }}

),

contests as (

    select *
    from {{ ref('dim_seven_days__contests') }}

),

prod_entries as (

    select
        e.entry_id,
        e.purchase_id,
        e.user_id,
        e.client_id,
        e.tenant_id,
        e.tenant_name,
        e.game_type,
        e.entered_at,
        e.entry_date_uk,
        e.entry_fee,
        c.game_name,
        c.game_theme,
        c.ticket_price
    from entries as e
    inner join contests as c
        on e.contest_id = c.contest_id
    where c.is_prod

),

-- The player's first entry (and the purchase containing it) on the site, and of each game.
first_entries as (

    select
        *,
        first_value(entry_id) over (
            partition by tenant_id, user_id
            order by entered_at, entry_id
        )                                                   as first_site_entry_id,
        first_value(purchase_id) over (
            partition by tenant_id, user_id
            order by entered_at, entry_id
        )                                                   as first_site_purchase_id,
        first_value(entry_id) over (
            partition by tenant_id, user_id, game_name
            order by entered_at, entry_id
        )                                                   as first_game_entry_id,
        first_value(purchase_id) over (
            partition by tenant_id, user_id, game_name
            order by entered_at, entry_id
        )                                                   as first_game_purchase_id
    from prod_entries

),

daily as (

    select
        entry_date_uk,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        game_name,
        game_theme,
        ticket_price,
        count(*)                                                        as entries,
        count_if(entry_id = first_site_entry_id)                        as new_to_site_entries,
        count_if(entry_id = first_game_entry_id)                        as new_to_game_entries,
        count(distinct purchase_id)                                     as purchases,
        count(distinct case when purchase_id = first_site_purchase_id then purchase_id end)
                                                                        as new_to_site_purchases,
        count(distinct case when purchase_id = first_game_purchase_id then purchase_id end)
                                                                        as new_to_game_purchases,
        sum(entry_fee)                                                  as gross_revenue,
        coalesce(sum(case when purchase_id = first_site_purchase_id then entry_fee end), 0)
                                                                        as new_to_site_gross_revenue,
        coalesce(sum(case when purchase_id = first_game_purchase_id then entry_fee end), 0)
                                                                        as new_to_game_gross_revenue
    from first_entries
    group by 1, 2, 3, 4, 5, 6, 7, 8

),

final as (

    select
        entry_date_uk,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        game_name,
        game_theme,
        case when ticket_price < 1 then 'Low' else 'High' end          as price_tier,
        game_name || ' - ' || case when ticket_price < 1 then 'Low' else 'High' end
                                                                        as game_price_tier,
        ticket_price,
        entries,
        new_to_site_entries,
        new_to_game_entries,
        purchases,
        new_to_site_purchases,
        new_to_game_purchases,
        gross_revenue,
        new_to_site_gross_revenue,
        new_to_game_gross_revenue
    from daily

)

select * from final
