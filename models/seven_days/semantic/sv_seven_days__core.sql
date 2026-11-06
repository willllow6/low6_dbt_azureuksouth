-- Snowflake semantic view over the seven_days core facts and dimensions, for Cortex Analyst /
-- Snowflake Intelligence agents. Body is passed straight to CREATE SEMANTIC VIEW by the
-- dbt_semantic_view package. persist_docs doesn't reach semantic views, so everything the
-- agent needs to know is in the inline COMMENTs and AI_SQL_GENERATION below.
-- Names are unique across the whole view; avoid apostrophes in comments (or double them).
-- Expressions can only reach another table when there is a single join path, so entries
-- relate to contests and users directly, not via purchases or prizes. Realised payout needs
-- the won prize value on fct_seven_days__entries before it can be a metric here.
{{ config(materialized='semantic_view', copy_grants=true) }}

tables (

    entries as {{ ref('fct_seven_days__entries') }}
        primary key (entry_id)
        with synonyms = ('tickets', 'plays', 'ticket sales')
        comment = 'One row per entry (one ticket). A purchase buys one or more tickets; each ticket instantly reveals a prize or no win. Includes test instances: filter contests.is_prod.',

    purchases as {{ ref('fct_seven_days__purchases') }}
        primary key (purchase_id)
        with synonyms = ('sessions', 'baskets', 'orders', 'transactions')
        comment = 'One row per purchase (session), which buys one or more tickets in one game instance. purchase_price = tickets * ticket_price.',

    user_activity as {{ ref('fct_seven_days__user_activity_daily') }}
        primary key (tenant_id, user_id, activity_date_uk)
        with synonyms = ('daily activity', 'active days')
        comment = 'One row per player per site per UK day with at least one entry. Use for DAU / WAU / MAU style active player counts.',

    contests as {{ ref('dim_seven_days__contests') }}
        primary key (contest_id)
        with synonyms = ('game instances', 'instances', 'raffles', 'games')
        comment = 'One row per game instance: one game on one site, 1:1 with a raffle. An instance is typically on sale for about 7 days before a new instance of the same game replaces it.',

    users as {{ ref('dim_seven_days__users') }}
        primary key (tenant_id, user_id)
        with synonyms = ('players', 'customers')
        comment = 'One row per player per site, from production entries only. User ids are site-scoped. No registration data exists: first entry stands in for registration.',

    prizes as {{ ref('dim_seven_days__prizes') }}
        primary key (prize_id)
        with synonyms = ('prize list', 'prize table')
        comment = 'One row per prize per game instance, from the raffle prize list. Odds are per ticket. prize_value is known for credit and cash prizes and some items; null for most items.'

)

relationships (

    entries_to_contests     as entries (contest_id)         references contests,
    entries_to_users        as entries (tenant_id, user_id) references users,
    purchases_to_contests   as purchases (contest_id)       references contests,
    purchases_to_users      as purchases (tenant_id, user_id) references users,
    user_activity_to_users  as user_activity (tenant_id, user_id) references users,
    prizes_to_contests      as prizes (contest_id)          references contests

)

facts (

    entries.entry_fee as entry_fee
        comment = 'Ticket price paid for this entry, GBP.',
    entries.won_prize_amount as won_prize_amount
        comment = 'Amount stated on the ticket for site credit prizes, GBP. Null for cash and item prizes.',

    purchases.tickets as tickets
        comment = 'Number of tickets bought in the purchase.',
    purchases.purchase_price as purchase_price
        comment = 'Total spend on the purchase, GBP.',

    user_activity.daily_entries as entries
        comment = 'Entries by the player on the site that UK day.',
    user_activity.daily_purchases as purchases
        comment = 'Purchases by the player on the site that UK day.',

    users.lifetime_spend as lifetime_spend
        comment = 'Total spend by the player on the site across all production instances, GBP.',
    users.lifetime_entries as lifetime_entries
        comment = 'Total tickets bought by the player on the site.',
    users.lifetime_purchases as lifetime_purchases
        comment = 'Total purchases by the player on the site.',

    prizes.prize_value as prize_value
        comment = 'Known prize value, GBP. Null when unknown.',
    prizes.prize_probability as prize_probability
        comment = 'Probability that one ticket wins this prize.',
    prizes.rtp_contribution as expected_value_per_ticket / nullif(contests.ticket_price, 0)
        comment = 'This prize''s contribution to theoretical return to player: expected value per ticket / ticket price. Valued prizes only.'

)

dimensions (

    -- entries
    entries.entered_at as entered_at
        comment = 'When the ticket was bought, UTC.',
    entries.entry_date_uk as entry_date_uk
        with synonyms = ('date', 'sale date', 'day')
        comment = 'UK calendar date of the entry. Use for daily / weekly / monthly trends.',
    entries.is_winner as is_winner
        with synonyms = ('won', 'winning ticket')
        comment = 'True when the ticket revealed a prize.',
    entries.won_prize_type as won_prize_type
        comment = 'Prize type stated on the winning ticket.',
    entries.user_entry_number as user_entry_number
        comment = 'The player''s nth ticket on the site (1 = first ever).',
    entries.player_tenure as case
            when date_trunc('week', entries.entry_date_uk) = date_trunc('week', users.first_entry_date_uk)
                then 'new'
            else 'existing'
        end
        with synonyms = ('new vs existing', 'new or returning', 'player type')
        comment = 'new when the entry is in the same UK week as the player''s first ever entry on the site, else existing.',
    entries.day_of_instance as datediff(
            day,
            cast(convert_timezone('UTC', '{{ var("local_timezone") }}', contests.starts_at) as date),
            entries.entry_date_uk
        ) + 1
        comment = 'Day number of the entry within its game instance (1 = day of first sale). Use for within-instance lifecycle patterns.',
    entries.is_last_day_of_instance as entries.entry_date_uk
            = cast(convert_timezone('UTC', '{{ var("local_timezone") }}', contests.last_sale_at) as date)
        comment = 'True when the entry was on the UK day of the instance''s last sale, typically when the game reaches the top row of the page.',

    -- purchases
    purchases.purchased_at as purchased_at
        comment = 'When the purchase was made, UTC.',
    purchases.purchase_date_uk as purchase_date_uk
        comment = 'UK calendar date of the purchase.',

    -- user activity
    user_activity.activity_date_uk as activity_date_uk
        with synonyms = ('active date')
        comment = 'UK calendar date the player was active (bought at least one ticket).',

    -- contests
    contests.contest_id as contest_id
        comment = 'Game instance id.',
    contests.tenant_name as tenant_name
        with synonyms = ('site', 'operator', 'tenant', 'brand')
        comment = 'Site the instance ran on: 7 Days Performance (larger, most revenue) or UKCC.',
    contests.game_name as game_name
        with synonyms = ('game', 'scratchcard')
        comment = 'Base game name, with any theme removed. One game runs as many consecutive instances.',
    contests.game_theme as game_theme
        comment = 'Themed variant: Football or Christmas. Null for unthemed games.',
    contests.contest_name as contest_name
        comment = 'Instance name. Test for non-production instances.',
    contests.contest_status as contest_status
        comment = 'test (no ticket price or no entries), live (entries today, UK time) or closed.',
    contests.is_prod as is_prod
        with synonyms = ('production', 'real game')
        comment = 'False for test instances. Filter is_prod = true unless asked about test games.',
    contests.ticket_price as ticket_price
        with synonyms = ('price', 'price point', 'stake')
        comment = 'Ticket price of the instance, GBP.',
    contests.price_tier as case when contests.ticket_price < 1 then 'Low' else 'High' end
        with synonyms = ('price band')
        comment = 'Low: ticket under 1 GBP (favoured by new players). High: 1 GBP or more (existing players and big spenders, most revenue).',
    contests.starts_at as starts_at
        comment = 'First observed sale of the instance, UTC.',
    contests.ends_at as ends_at
        comment = 'Last observed sale, UTC. Null while the instance is still selling.',
    contests.last_sale_at as last_sale_at
        comment = 'Most recent sale of the instance so far, UTC, including live instances.',

    -- users
    users.user_id as user_id
        comment = 'Player id. Site-scoped: the same id on two sites is not the same person.',
    users.player_tenant_name as tenant_name
        with synonyms = ('player site')
        comment = 'Site the player belongs to. Use with user_activity metrics.',
    users.first_entry_date_uk as first_entry_date_uk
        with synonyms = ('cohort date', 'first play date', 'acquisition date')
        comment = 'UK date of the player''s first ever entry on the site. Stands in for registration date.',
    users.first_game_name as first_game_name
        comment = 'Game of the player''s first entry on the site.',
    users.favourite_game_name as favourite_game_name
        comment = 'Game the player has spent most on.',
    users.main_price_tier as main_price_tier
        comment = 'Price tier (Low / High) the player has spent most on.',
    users.spend_segment as spend_segment
        with synonyms = ('player segment', 'value segment')
        comment = 'Lifetime spend segment: whale (500+ GBP), big_spender (100+ GBP), regular (2+ purchases), one_off. Revenue is concentrated in whales and big spenders.',
    users.lifecycle_status as lifecycle_status
        comment = 'Relative to today (UK): active (last entry within 7 days), lapsing (within 28), lapsed. Lapsed from our games only: the player may still play competitor games on the site.',

    -- prizes
    prizes.prize_name as prize_name
        comment = 'Prize name from the raffle prize list.',
    prizes.prize_tier as prize_tier
        comment = 'Prize tier; tier 1 is the top prize.',
    prizes.prize_category as prize_category
        comment = 'site_credit, cash or item.'

)

metrics (

    -- entries
    entries.total_entries as count(entries.entry_id)
        with synonyms = ('tickets sold', 'plays', 'entries')
        comment = 'Number of tickets sold.',
    entries.gross_revenue as sum(entries.entry_fee)
        with synonyms = ('revenue', 'sales', 'spend', 'turnover', 'GGR')
        comment = 'Ticket sales, GBP. Before prizes.',
    entries.unique_players as count(distinct entries.tenant_id || '|' || entries.user_id)
        with synonyms = ('players', 'entrants', 'active players')
        comment = 'Distinct players who bought at least one ticket (site-scoped ids).',
    entries.revenue_per_player as entries.gross_revenue / nullif(entries.unique_players, 0)
        with synonyms = ('ARPU', 'spend per player')
        comment = 'Gross revenue per unique player, GBP.',
    entries.winning_entries as count_if(entries.is_winner)
        comment = 'Tickets that revealed a prize.',
    entries.win_rate as entries.winning_entries / nullif(entries.total_entries, 0)
        comment = 'Share of tickets that revealed a prize.',
    entries.credit_won as sum(entries.won_prize_amount)
        comment = 'Site credit won, GBP.',

    -- purchases
    purchases.total_purchases as count(purchases.purchase_id)
        with synonyms = ('baskets', 'orders')
        comment = 'Number of purchases.',
    purchases.purchase_revenue as sum(purchases.purchase_price)
        comment = 'Spend across purchases, GBP. Equals gross_revenue.',
    purchases.avg_tickets_per_purchase as avg(purchases.tickets)
        with synonyms = ('basket size')
        comment = 'Average tickets per purchase.',
    purchases.avg_basket_value as avg(purchases.purchase_price)
        with synonyms = ('average order value', 'AOV')
        comment = 'Average spend per purchase, GBP.',

    -- user activity
    user_activity.active_players as count(distinct user_activity.tenant_id || '|' || user_activity.user_id)
        with synonyms = ('DAU', 'WAU', 'MAU', 'active users')
        comment = 'Distinct active players. Grouped by day gives DAU, by week WAU, by month MAU.',
    user_activity.active_player_days as count(*)
        comment = 'Player-days of activity.',

    -- contests
    contests.instance_count as count(contests.contest_id)
        with synonyms = ('number of games', 'number of instances')
        comment = 'Number of game instances.',

    -- users
    users.player_count as count(users.user_id)
        with synonyms = ('number of players', 'total players')
        comment = 'Players (one per site).',
    users.avg_lifetime_spend as avg(users.lifetime_spend)
        with synonyms = ('LTV', 'lifetime value')
        comment = 'Average lifetime spend per player, GBP.',
    users.total_lifetime_spend as sum(users.lifetime_spend)
        comment = 'Lifetime spend summed over players, GBP.',

    -- prizes
    prizes.theoretical_rtp as sum(prizes.rtp_contribution) / nullif(count(distinct prizes.contest_id), 0)
        with synonyms = ('theoretical return to player', 'expected RTP')
        comment = 'Average theoretical RTP per instance from prize odds x value. Valued prizes only, so it understates instances with unvalued item prizes.'

)

comment = '7 Days Performance instant-win games run by Low6: tickets (entries), purchases, daily player activity, game instances, players and prizes, across two sites (7 Days Performance and UKCC).'

ai_sql_generation $$
Business context
- Client: 7 Days Performance (client_id = 7days_performance). Low6 runs paid instant-win scratchcard / raffle games for them on two sites (tenants):
  - 7 Days Performance (tenant_id = seven_days_performance, site 1): the larger site, which drives most of the revenue.
  - UKCC (tenant_id = ukcc, site 2): the smaller site.
- Players buy one or more tickets (entries) in a purchase. Each ticket instantly reveals a prize (site credit, cash or an item) or no win.
- The games sit in the Tap and Win section of each site (https://7daysperformance.co.uk/ and https://ukcc.co.uk/tap-and-win), alongside competitor games. This data covers our games only: competitor sales, and players who moved to competitor games, are not visible.

Market history
- Low6 had a monopoly on the Tap and Win section until competitor games launched.
- Gross revenue has dropped over time as more games have been released into the section.

Player behaviour and revenue concentration
- New players tend to start on the low-priced games (price_tier Low, under 1 GBP).
- Existing players, and especially big spenders and whales, play the high-priced games (price_tier High). These drive most of the revenue, so revenue is concentrated in a small group of players.
- When explaining a revenue trend, always segment by new vs existing players (entries.player_tenure), by spend segment (users.spend_segment) and by price tier (contests.price_tier), not only totals.

Page placement and the instance lifecycle
- Games on the page are ordered by ending soonest.
- A game instance is typically on sale for about 7 days before a new instance of that game replaces it.
- Revenue within an instance rises when the game reaches the top row of the page, typically on its last day (entries.is_last_day_of_instance, entries.day_of_instance). The top row shows 2 games on mobile and 4 on web.
- The client plans to change the section to a carousel; no details are known yet. Treat a change in this pattern after that launch as possibly caused by the redesign.

Vocabulary
- A game (game_name) is a base game, which can run in themed variants (Football / Christmas / Halloween / High Roller).
- A contest / game instance is one game on one site, 1:1 with a raffle.
- Site = tenant = tenant_name.

Rules
- Always filter contests.is_prod = true unless the question is about test games.
- Report per site by default. User ids are site-scoped: never treat the same id on two sites as one person.
- Use the _uk dates for days, weeks and months. Weeks start on Monday. All money is GBP.
- Do not use is_played.
- There is no registration data: a player first entry stands in for registration.
- Lapsed means lapsed from our games only.
- theoretical_rtp covers valued prizes only and understates the true figure. Realised payout is not in this view.
$$
