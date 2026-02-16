with

tenants as (

    select *
    from {{ ref('stg_prizekings_comps__tenants') }}

),

translations as (

    select *
    from {{ ref('stg_prizekings_comps__translations') }}
    where data_type in ('raffle','competition')

),

joined as (

    select
        translations.translation_id,
        translations.competition_sk,
        translations.language_id,
        tenants.tenant_id,

        tenants.tenant_name,
        translations.translation_name as competition_name,
        translations.translation_description as competition_description
    from translations
    inner join tenants 
        on translations.language_id = tenants.default_language_id
    
)

select * from joined