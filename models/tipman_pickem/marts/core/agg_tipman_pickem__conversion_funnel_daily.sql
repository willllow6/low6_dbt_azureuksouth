-- Each row is a registration cohort date. Metrics show what fraction of users who registered
-- on date_day went on to activate and return — not a running total.
with

users as (

    select
        user_id,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', registered_at) as date) as registration_date
    from {{ ref('dim_tipman_pickem__users') }}

),

entry_summary as (

    select
        user_id,
        count(entry_id) as total_entries
    from {{ ref('fct_tipman_pickem__entries') }}
    group by user_id

),

cohort as (

    select
        users.registration_date as date_day,
        users.client_id,
        users.tenant_id,
        users.tenant_name,
        users.game_type,
        count(distinct users.user_id) as registered,
        count(distinct case
            when es.total_entries >= 1
            then users.user_id
        end) as activated,
        count(distinct case
            when es.total_entries >= 2
            then users.user_id
        end) as repeat_entrants
    from users
    left join entry_summary as es
        on users.user_id = es.user_id
    group by
        users.registration_date,
        users.client_id,
        users.tenant_id,
        users.tenant_name,
        users.game_type

)

select
    date_day,
    client_id,
    tenant_id,
    tenant_name,
    game_type,
    registered,
    activated,
    round(activated / nullif(registered, 0), 4) as activation_rate,
    repeat_entrants,
    round(repeat_entrants / nullif(activated, 0), 4) as repeat_rate
from cohort
