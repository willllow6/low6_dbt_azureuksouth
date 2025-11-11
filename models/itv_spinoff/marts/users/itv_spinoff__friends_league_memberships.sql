with

league_memberships as (

    select *
    from {{ ref('stg_itv_spinoff__friends_league_memberships') }}

),

leagues as (

    select *
    from {{ ref('stg_itv_spinoff__friends_leagues' )}}

),

users as (

    select *
    from {{ ref('itv_spinoff__users') }}

),

joined as (

    select
        league_memberships.league_membership_id,
        league_memberships.league_id,
        leagues.creator_user_id,
        league_memberships.user_id as member_user_id,

        leagues.league_name,
        leagues.league_code,
        leagues.league_created_date,
        leagues.created_at as league_created_at,

        creators.username as creator_username,
        
        members.username as member_username,

        league_memberships.joined_date,
        league_memberships.joined_at

    from league_memberships
    left join leagues
        on league_memberships.league_id = leagues.league_id
    left join users as creators 
        on leagues.creator_user_id = creators.user_id
    left join users as members 
        on league_memberships.user_id = members.user_id
        
)

select * from joined