with

competitions as (

    select *
    from {{ ref('int_prizekings_comps__competitions_unioned') }}

),

translations as (

    select *
    from {{ ref('int_prizekings_comps__competition_translations') }}

),

joined as (

    select
        competitions.competition_sk,
        competitions.tenant_id,
        translations.tenant_name,
        translations.competition_name,
        translations.competition_description,
        competitions.competition_type,
        competitions.competition_status,
        competitions.entry_price,
        competitions.starts_at,
        competitions.ends_at
    from competitions 
    left join translations
        on competitions.competition_sk = translations.competition_sk
        and competitions.tenant_id = translations.tenant_id

)

select * from joined
