with

entries as (

    select *
    from {{ ref('fct_prizekings_comps__competition_entries') }}

),

competitions as (

    select *
    from {{ ref('dim_prizekings_comps__competitions') }}

),

prizes as (

    select *
    from {{ ref('dim_prizekings_comps__prizes') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

)

select
    e.entry_sk,
    e.competition_sk,
    e.user_id,
    e.prize_sk,
    e.is_winner,
    e.user_entry_number,
    c.competition_name,
    c.competition_type,
    c.competition_status,
    c.entry_price,
    c.starts_at,
    c.ends_at,
    p.prize_type,
    p.value as prize_value,
    t.tenant_name,
    e.created_at
from entries as e
inner join competitions as c
    on e.competition_sk = c.competition_sk
left join prizes as p
    on e.prize_sk = p.prize_sk
left join tenants as t
    on c.tenant_id = t.tenant_id
