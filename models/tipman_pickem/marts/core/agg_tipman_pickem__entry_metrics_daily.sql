with

entries as (

    select
        entry_id,
        user_id,
        contest_id,
        client_id,
        tenant_id,
        game_type,
        entry_number,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date) as entry_date
    from {{ ref('fct_tipman_pickem__entries') }}

),

tenants as (

    select tenant_id, tenant_name
    from {{ ref('dim_tipman_pickem__tenants') }}

),

daily as (

    select
        entries.entry_date as date_day,
        entries.client_id,
        entries.tenant_id,
        tenants.tenant_name,
        entries.game_type,
        count(distinct entries.contest_id) as contests_active,
        count(entries.entry_id) as total_entries,
        count(distinct entries.user_id) as unique_entrants,
        count(distinct case
            when entries.entry_number = 1
            then entries.user_id
        end) as first_time_entrants
    from entries
    left join tenants
        on entries.tenant_id = tenants.tenant_id
    group by
        entries.entry_date,
        entries.client_id,
        entries.tenant_id,
        tenants.tenant_name,
        entries.game_type

)

select * from daily
