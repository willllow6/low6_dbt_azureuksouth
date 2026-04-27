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

entries as (

    select
        user_id,
        client_id,
        tenant_id,
        game_type,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date) as entry_date
    from {{ ref('fct_tipman_pickem__entries') }}

),

daily_registrations as (

    select
        registration_date as date_day,
        client_id,
        tenant_id,
        tenant_name,
        game_type,
        count(distinct user_id) as new_registrations
    from users
    group by
        registration_date,
        client_id,
        tenant_id,
        tenant_name,
        game_type

),

daily_active as (

    select
        entries.entry_date as date_day,
        entries.client_id,
        entries.tenant_id,
        users.tenant_name,
        entries.game_type,
        count(distinct entries.user_id) as dau,
        count(distinct case
            when users.registration_date < entries.entry_date
            then entries.user_id
        end) as returning_users
    from entries
    left join users
        on entries.user_id = users.user_id
    group by
        entries.entry_date,
        entries.client_id,
        entries.tenant_id,
        users.tenant_name,
        entries.game_type

),

combined as (

    select
        coalesce(dr.date_day, da.date_day) as date_day,
        coalesce(dr.client_id, da.client_id) as client_id,
        coalesce(dr.tenant_id, da.tenant_id) as tenant_id,
        coalesce(dr.tenant_name, da.tenant_name) as tenant_name,
        coalesce(dr.game_type, da.game_type) as game_type,
        coalesce(da.dau, 0) as dau,
        coalesce(dr.new_registrations, 0) as new_registrations,
        coalesce(da.returning_users, 0) as returning_users
    from daily_registrations as dr
    full outer join daily_active as da
        on dr.date_day = da.date_day
        and dr.client_id = da.client_id
        and dr.tenant_id = da.tenant_id

)

select * from combined
