with

users as (

    select *
    from {{ ref('stg_engagecraft_fantasy__users') }}

),

dreamteam_game_registrations as (

    select *
    from {{ ref('stg_engagecraft_fantasy__dreamteam_game_registrations') }}

),

-- previous supplier's 2025-26 fantasy players; a match means a returning user
dreamteam_fantasy_users as (

    select distinct cpn
    from dreamteam_game_registrations
    where dreamteam_game_type = 'fantasy'

)

select
    users.user_id,
    users.client_id,
    users.tenant_id,
    users.tenant_name,
    users.game_type,
    users.engagecraft_id,
    users.ref_id,
    users.username,
    users.favourite_club_id,
    users.country_code,
    users.created_at,
    users.updated_at,
    users.last_login_at,
    dreamteam_fantasy_users.cpn is not null as is_returning_dreamteam_user
from users
left join dreamteam_fantasy_users
    on upper(trim(users.ref_id)) = dreamteam_fantasy_users.cpn
