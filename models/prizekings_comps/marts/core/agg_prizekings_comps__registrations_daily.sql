with

registrations as (

    select *
    from {{ ref('mart_prizekings_comps__registrations') }}

),

daily_registrations as (

    select
        cast(created_at as date) as date_day,
        client_id,
        game_type,
        tenant_name,
        roles,
        is_active,
        count(*) as registrations
    from registrations
    group by 1, 2, 3, 4, 5, 6

)

select * from daily_registrations
