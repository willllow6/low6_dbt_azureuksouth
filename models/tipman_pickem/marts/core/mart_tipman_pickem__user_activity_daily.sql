with

entries as (

    select
        user_id,
        client_id,
        tenant_id,
        game_type,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date) as activity_date,
        count(entry_id) as entries_count,
        count(distinct contest_id) as contests_entered,
        sum(total_points) as total_points
    from {{ ref('fct_tipman_pickem__entries') }}
    group by
        user_id,
        client_id,
        tenant_id,
        game_type,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', entered_at) as date)

),

users as (

    select
        user_id,
        tenant_name,
        registration_type,
        external_user_id,
        username,
        email,
        registered_at
    from {{ ref('dim_tipman_pickem__users') }}

),

joined as (

    select
        entries.activity_date,
        entries.user_id,
        entries.client_id,
        entries.tenant_id,
        users.tenant_name,
        entries.game_type,

        users.username,
        users.email,
        users.external_user_id,
        users.registration_type,
        users.registered_at,

        entries.entries_count,
        entries.contests_entered,
        entries.total_points

    from entries
    left join users
        on entries.user_id = users.user_id

)

select * from joined
