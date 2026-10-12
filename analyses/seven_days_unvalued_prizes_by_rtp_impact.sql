-- Unvalued seven_days prize names ranked by how much estimated RTP they carry across live
-- instances. The top names are the ones worth valuing by hand in seeds/seven_days_prize_values.csv.
-- Run: dbt show --select seven_days_unvalued_prizes_by_rtp_impact --limit 50

with

prizes as (

    select *
    from {{ ref('dim_seven_days__prizes') }}

),

prize_tiers as (

    select *
    from {{ ref('rpt_seven_days__contest_prize_tier_summary') }}

),

contests as (

    select *
    from {{ ref('rpt_seven_days__contest_performance_summary') }}

),

-- live and closed instances, excluding broken prize configs (odds summing above 1)
in_scope as (

    select contest_id
    from contests
    where contest_status != 'test'
        and win_probability <= 1

),

unvalued as (

    select
        upper(trim(p.prize_name))                           as prize_name,
        p.contest_id,
        p.prize_tier,
        p.prize_probability * t.tier_avg_prize_value / nullif(t.ticket_price, 0)
                                                            as rtp_points,
        t.tier_avg_prize_value
    from prizes as p
    inner join in_scope as s
        on p.contest_id = s.contest_id
    inner join prize_tiers as t
        on  p.contest_id = t.contest_id
        and p.prize_tier = t.prize_tier
    where p.prize_value is null
        and p.odds_denominator < 2147483647

),

by_name as (

    select
        prize_name,
        count(distinct contest_id)                          as instances,
        min(prize_tier)                                     as min_tier,
        max(prize_tier)                                     as max_tier,
        round(median(tier_avg_prize_value))                 as estimated_value,
        sum(rtp_points)                                     as rtp_points
    from unvalued
    group by 1
    having sum(rtp_points) is not null

),

final as (

    select
        row_number() over (order by rtp_points desc)        as rank,
        prize_name,
        instances,
        min_tier,
        max_tier,
        estimated_value,
        round(
            100 * sum(rtp_points) over (order by rtp_points desc rows unbounded preceding)
                / sum(rtp_points) over (),
            1
        )                                                   as cumulative_pct_of_uplift
    from by_name

)

select * from final
order by rank
