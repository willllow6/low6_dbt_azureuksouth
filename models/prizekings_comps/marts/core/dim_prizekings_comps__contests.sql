with

contests as (

    select *
    from {{ ref('int_prizekings_comps__contests_unioned') }}

),

titles as (

    select *
    from {{ ref('stg_prizekings_comps__translations') }}
    where data_type in ('raffle', 'competition')
    and translation_name is not null

),

joined as (

    select
        contests.contest_sk,
        contests.tenant_id,
        contests.client_id,
        contests.game_type,
        titles.translation_name as contest_name,
        titles.translation_description as contest_description,
        contests.contest_type,
        contests.contest_status,
        contests.is_active,
        contests.entry_fee,
        contests.starts_at,
        contests.ends_at
    from contests
    left join titles
        on contests.contest_sk = titles.contest_sk

)

select * from joined
