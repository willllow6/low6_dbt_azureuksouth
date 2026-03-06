with

competitions as (

    select *
    from {{ ref('int_prizekings_comps__competitions_unioned') }}

),

titles as (

    select *
    from {{ ref('stg_prizekings_comps__translations') }}
    where data_type in ('raffle','competition')
    and translation_name is not null

),

joined as (

    select
        competitions.competition_sk,
        competitions.tenant_id,
        titles.translation_name as competition_name,
        titles.translation_description as competition_description,
        competitions.competition_type,
        competitions.competition_status,
        competitions.entry_price,
        competitions.starts_at,
        competitions.ends_at
    from competitions 
    left join titles
        on competitions.competition_sk = titles.competition_sk

)

select * from joined
