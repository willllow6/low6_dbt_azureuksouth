with

source as (

    select *
    from {{ source('prizekings_comps','competition_entry') }}

),

renamed as (

    select

        ----------  ids
        id as entry_id,
        'STB_' || id as entry_sk,
        competition_id as contest_id,
        'STB_' || competition_id as contest_sk,
        user_id,
        prize_id,
        case
            when prize_id is not null
                then 'STB_' || prize_id
            else null
        end as prize_sk,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,

        ---------- numerics
        pos as position,

        ---------- booleans
        case
            when prize_id is not null
                then true
            else false
        end as is_winner,

        ---------- dates

        ---------- timestamps
        created_at as entered_at,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed