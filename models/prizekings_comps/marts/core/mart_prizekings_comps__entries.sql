with

entries as (

    select *
    from {{ ref('fct_prizekings_comps__entries') }}

),

contests as (

    select *
    from {{ ref('dim_prizekings_comps__contests') }}

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
    e.contest_sk,
    e.user_id,
    e.client_id,
    e.game_type,
    e.tenant_id,
    t.tenant_name,
    e.prize_sk,
    e.is_winner,
    e.user_entry_number,
    c.contest_name,
    c.contest_type,
    c.contest_status,
    c.entry_fee,
    c.starts_at,
    c.ends_at,
    p.prize_type,
    p.prize_name,
    p.value as prize_value,
    e.entered_at,
    e.created_at
from entries as e
inner join contests as c
    on e.contest_sk = c.contest_sk
left join prizes as p
    on e.prize_sk = p.prize_sk
left join tenants as t
    on e.tenant_id = t.tenant_id
