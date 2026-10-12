-- Grain change: raffle prize list → prize (one row per prize per game instance).
-- Odds are "1 in N". A cash value is parsed from the prize name where it states one
-- ("£2,000 Cash", "£0.30 Site Credit", "80P SITE CREDIT"); items have no value here.

with

prize_arrays as (

    select *
    from {{ ref('stg_seven_days__instance_prize_arrays') }}

),

games as (

    select *
    from {{ ref('stg_seven_days__games') }}

),

flattened as (

    select
        g.contest_id,
        p.raffle_id,
        p.site_id,
        p.client_id,
        p.tenant_id,
        p.tenant_name,
        p.game_type,
        f.index                                     as prize_sort_order,
        f.value:instantWinGroupId::varchar          as prize_id,
        f.value:prizeTier::int                      as prize_tier,
        trim(f.value:name::string)                  as prize_name,
        f.value:type::string                        as source_prize_type,
        f.value:value::string                       as prize_odds,
        f.value:description::string                 as prize_description,
        try_to_number(f.value:extraCash::string, 12, 2) as extra_cash
    from prize_arrays as p
    inner join games as g
        on  p.site_id = g.site_id
        and p.raffle_id = g.raffle_id,
        lateral flatten(input => p.payload:data:prizes) as f

),

parsed as (

    select
        contest_id,
        raffle_id,
        site_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        prize_id,
        prize_sort_order,
        prize_tier,
        prize_name,
        source_prize_type,
        prize_description,
        prize_odds,
        try_to_number(regexp_substr(prize_odds, '[0-9]+$'))         as odds_denominator,
        1 / nullif(
            try_to_number(regexp_substr(prize_odds, '[0-9]+$')), 0
        )::float                                                    as prize_probability,
        coalesce(
            try_to_number(
                replace(regexp_substr(prize_name, '£([0-9,]+(\\.[0-9]+)?)', 1, 1, 'e', 1), ','),
                12, 2
            ) * iff(regexp_like(prize_name, '.*£[0-9,.]+k([^a-z].*)?', 'i'), 1000, 1),
            try_to_number(regexp_substr(prize_name, '^([0-9]+)p ', 1, 1, 'ie', 1)) / 100
        )                                                           as parsed_prize_value,
        extra_cash
    from flattened

)

select * from parsed
