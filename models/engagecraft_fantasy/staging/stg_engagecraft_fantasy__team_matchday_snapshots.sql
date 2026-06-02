with

source as (

    select *
    from {{ source('engagecraft_fantasy', 'fantasy_team_matchday_snapshot') }}

),

renamed as (

    select

        ---------- ids
        id as snapshot_id,
        fantasy_team_id,
        matchday_id,

        ---------- strings
        'engagecraft' as client_id,
        'engagecraft' as tenant_id,
        'engagecraft' as tenant_name,
        'fantasy' as game_type,

        ---------- numerics
        total_points,
        rank as matchday_rank,

        ---------- timestamps
        created_at::timestamp_ntz as created_at,
        updated_at::timestamp_ntz as updated_at

    from source

)

select * from renamed
