with

entries as (

    select
        entry_id,
        user_id,
        client_id,
        tenant_id,
        game_type,
        entry_number,
        convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as entered_at_local
    from {{ ref('fct_tipman_pickem__entries') }}

),

tenants as (

    select tenant_id, tenant_name
    from {{ ref('dim_tipman_pickem__tenants') }}

),

hourly as (

    select
        cast(entered_at_local as date) as date_day,
        hour(entered_at_local) as hour_of_day,
        lpad(hour(entered_at_local)::varchar, 2, '0') || ':00 - '
            || lpad(hour(entered_at_local)::varchar, 2, '0') || ':59' as hour_label,
        entries.client_id,
        entries.tenant_id,
        tenants.tenant_name,
        entries.game_type,
        count(entries.entry_id) as total_entries,
        count(distinct entries.user_id) as unique_entrants,
        count(case when entries.entry_number = 1 then entries.entry_id end) as first_time_entrants
    from entries
    left join tenants
        on entries.tenant_id = tenants.tenant_id
    group by
        cast(entered_at_local as date),
        hour(entered_at_local),
        lpad(hour(entered_at_local)::varchar, 2, '0') || ':00 - '
            || lpad(hour(entered_at_local)::varchar, 2, '0') || ':59',
        entries.client_id,
        entries.tenant_id,
        tenants.tenant_name,
        entries.game_type

)

select * from hourly
