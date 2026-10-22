with

-- itv_spinoff as (

--     select
--         '1155' as app_id,
--         count(distinct user_id || '-' || quiz_id) as entries,
--         count(distinct case when cast(started_at as date) = current_date() - 1 then user_id || '-' || quiz_id else null end) as yesterday_entries,
--         count(distinct case when started_at >= current_date() - 8 and started_at < current_date() then user_id || '-' || quiz_id else null end) as last_7_days_entries,
--         count(distinct case when started_at >= current_date() - 29 and started_at < current_date() then user_id || '-' || quiz_id else null end) as last_28_days_entries,
--         count(distinct user_id) as entrants,
--         count(distinct case when cast(started_at as date) = current_date() - 1 then user_id else null end) as yesterday_entrants,
--         count(distinct case when started_at >= current_date() - 8 and started_at < current_date() then user_id else null end) as last_7_days_entrants,
--         count(distinct case when started_at >= current_date() - 29 and started_at < current_date() then user_id else null end) as last_28_days_entrants,
--         count(distinct quiz_id) as contests,
--         max(cast(started_at as date)) as last_entry_date
--     from  {{ source('itv_spinoff','quiz_attempt') }}
--     group by 1

-- ),

prizekings as (

    select
        case
            when tenant_name = 'United Kingdom'
                then 'pkuk'
            when tenant_name = 'South Africa'
                then 'pksa'
            else ''
        end as app_id,
        count(*) as entries,
        count_if(cast(created_at as date) = current_date() - 1) as yesterday_entries,
        count_if(cast(created_at as date) >= current_date() - 8 and cast(created_at as date) < current_date()) as last_7_days_entries,
        count_if(cast(created_at as date) >= current_date() - 29 and cast(created_at as date) < current_date()) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when cast(created_at as date) = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when cast(created_at as date) >= current_date() - 8 and cast(created_at as date) < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when cast(created_at as date) >= current_date() - 29 and cast(created_at as date) < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct contest_sk) as contests,
        max(cast(created_at as date)) as last_entry_date
    from  {{ ref('mart_prizekings_comps__entries') }}
    group by 1

),

pivot_bracket as (

    select
        'pvtbkt' as app_id,
        count(*) as entries,
        count_if(cast(created_at as date) = current_date() - 1) as yesterday_entries,
        count_if(cast(created_at as date) >= current_date() - 8 and cast(created_at as date) < current_date()) as last_7_days_entries,
        count_if(cast(created_at as date) >= current_date() - 29 and cast(created_at as date) < current_date()) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when cast(created_at as date) = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when cast(created_at as date) >= current_date() - 8 and cast(created_at as date) < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when cast(created_at as date) >= current_date() - 29 and cast(created_at as date) < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct bracket_id) as contests,
        max(cast(created_at as date)) as last_entry_date
    from  {{ source('pivot_bracket', 'user_selection') }}
    group by 1
    
),

-- One app_id per seven_days product; only the named contests are counted (test games and
-- variants such as 'Coin Drop Football' are excluded). session_date is the UTC entry date.
sevendays_entries as (

    select
        case c.contest_name
            when 'Pirate Quest' then '7dpq'
            when 'Coin Drop'    then '7dcd'
            when 'Drop Zone'    then '7ddz'
            when 'Alien Dash'   then '7dad'
            when 'Pinball'      then '7dpb'
        end as app_id,
        e.user_id,
        c.game_id,
        cast(e.entered_at as date) as session_date
    from {{ ref('fct_seven_days__entries') }} as e
    inner join {{ ref('dim_seven_days__contests') }} as c
        on e.contest_id = c.contest_id

),

sevendays as (

    select
        app_id,
        count(*) as entries,
        sum(case when session_date = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when session_date = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when session_date >= current_date() - 8 and session_date < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when session_date >= current_date() - 29 and session_date < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct game_id) as contests,
        max(session_date) as last_entry_date
    from sevendays_entries
    where app_id is not null
    group by 1

),

tipman_pickem as (

    select
        'tmpkm' as app_id,
        count(*) as entries,
        sum(case when entry_date_local = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when entry_date_local >= current_date() - 8 and entry_date_local < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when entry_date_local >= current_date() - 29 and entry_date_local < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when entry_date_local = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when entry_date_local >= current_date() - 8 and entry_date_local < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when entry_date_local >= current_date() - 29 and entry_date_local < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct contest_id) as contests,
        max(cast(entry_date_local as date)) as last_entry_date
    from {{ ref('mart_tipman_pickem__entries') }}
    group by 1  

),

engagecraft_fantasy as (

    select
        'engsdt' as app_id,
        count(*) as entries,
        sum(case when created_at = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when created_at >= current_date() - 8 and created_at < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when created_at >= current_date() - 29 and created_at < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when created_at = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when created_at >= current_date() - 8 and created_at < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when created_at >= current_date() - 29 and created_at < current_date() then user_id else null end) as last_28_days_entrants,
        1 as contests,
        max(cast(created_at as date)) as last_entry_date
    from {{ ref('dim_engagecraft_fantasy__fantasy_teams') }}
    group by 1  

),

tipman_pickem as (

    select
        'tmpkm' as app_id,
        count(*) as entries,
        sum(case when entry_date_local = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when entry_date_local >= current_date() - 8 and entry_date_local < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when entry_date_local >= current_date() - 29 and entry_date_local < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when entry_date_local = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when entry_date_local >= current_date() - 8 and entry_date_local < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when entry_date_local >= current_date() - 29 and entry_date_local < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct contest_id) as contests,
        max(cast(entry_date_local as date)) as last_entry_date
    from {{ ref('mart_tipman_pickem__entries') }}
    group by 1  

),

gaming1_pickem as (

    select
        'cirpkm' as app_id,
        count(*) as entries,
        sum(case when cast(entered_at as date) = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when cast(entered_at as date) >= current_date() - 8 and cast(entered_at as date) < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when cast(entered_at as date) >= current_date() - 29 and cast(entered_at as date) < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when cast(entered_at as date) = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when cast(entered_at as date) >= current_date() - 8 and cast(entered_at as date) < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when cast(entered_at as date) >= current_date() - 29 and cast(entered_at as date) < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct contest_id) as contests,
        max(cast(entered_at as date)) as last_entry_date
    from {{ ref('fct_gaming1__entries') }}
    where game_type = 'pickem'
)

-- select *
-- from itv_spinoff

-- union all

select *
from prizekings

union all


select *
from pivot_bracket

union all

select *
from sevendays

union all

select *
from tipman_pickem

union all

select *
from engagecraft_fantasy

union all

select *
from gaming1_pickem