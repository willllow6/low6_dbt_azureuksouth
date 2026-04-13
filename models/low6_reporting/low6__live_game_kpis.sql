with

itv_spinoff as (

    select
        '1155' as app_id,
        count(distinct user_id || '-' || quiz_id) as entries,
        count(distinct case when cast(started_at as date) = current_date() - 1 then user_id || '-' || quiz_id else null end) as yesterday_entries,
        count(distinct case when started_at >= current_date() - 8 and started_at < current_date() then user_id || '-' || quiz_id else null end) as last_7_days_entries,
        count(distinct case when started_at >= current_date() - 29 and started_at < current_date() then user_id || '-' || quiz_id else null end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when cast(started_at as date) = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when started_at >= current_date() - 8 and started_at < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when started_at >= current_date() - 29 and started_at < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct quiz_id) as contests,
        max(cast(started_at as date)) as last_entry_date
    from  {{ source('itv_spinoff','quiz_attempt') }}
    group by 1

),

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
        count(distinct competition_sk) as contests,
        max(cast(created_at as date)) as last_entry_date
    from  {{ ref('mart_prizekings_comps__competition_entries') }}
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

sevendays_pq as (

    select
        '7dpq' as app_id,
        count(*) as entries,
        sum(case when session_date = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when session_date = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when session_date >= current_date() - 8 and session_date < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when session_date >= current_date() - 29 and session_date < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct game_id) as contests,
        max(cast(session_date as date)) as last_entry_date
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Pirate Quest'
    group by 1

),

sevendays_cd as (

    select
        '7dcd' as app_id,
        count(*) as entries,
        sum(case when session_date = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when session_date = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when session_date >= current_date() - 8 and session_date < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when session_date >= current_date() - 29 and session_date < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct game_id) as contests,
        max(cast(session_date as date)) as last_entry_date
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Coin Drop'
    group by 1

),

sevendays_dz as (

    select
        '7ddz' as app_id,
        count(*) as entries,
        sum(case when session_date = current_date() - 1 then 1 else 0 end) as yesterday_entries,
        sum(case when session_date >= current_date() - 8 and session_date < current_date() then 1 else 0 end) as last_7_days_entries,
        sum(case when session_date >= current_date() - 29 and session_date < current_date() then 1 else 0 end) as last_28_days_entries,
        count(distinct user_id) as entrants,
        count(distinct case when session_date = current_date() - 1 then user_id else null end) as yesterday_entrants,
        count(distinct case when session_date >= current_date() - 8 and session_date < current_date() then user_id else null end) as last_7_days_entrants,
        count(distinct case when session_date >= current_date() - 29 and session_date < current_date() then user_id else null end) as last_28_days_entrants,
        count(distinct game_id) as contests,
        max(cast(session_date as date)) as last_entry_date
    from {{ ref('mart_seven_days__entries') }}
    where game_name = 'Drop Zone'
    group by 1

)



select *
from itv_spinoff

union all

select *
from prizekings

union all


select *
from pivot_bracket

union all

select *
from sevendays_pq

union all

select *
from sevendays_cd

union all

select *
from sevendays_dz