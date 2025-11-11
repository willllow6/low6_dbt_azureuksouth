with

league_memberships as (

    select *
    from {{ ref('itv_spinoff__friends_league_memberships') }}

),

league_membership_stats as (

    select
        league_name,
        league_created_date,
        joined_date,
        count(*) as league_memberships
    from league_memberships
    group by 1,2,3

)

select * from league_membership_stats