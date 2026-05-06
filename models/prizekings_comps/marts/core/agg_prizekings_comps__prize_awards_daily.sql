with

prize_awards as (

    select *
    from {{ ref('fct_prizekings_comps__prize_awards') }}

),

contests as (

    select *
    from {{ ref('dim_prizekings_comps__contests') }}

),

tenants as (

    select *
    from {{ ref('dim_prizekings_comps__tenants') }}

),

award_metrics as (

    select
        cast(p.awarded_at as date) as date_day,
        p.client_id,
        c.tenant_id,
        t.tenant_name,
        p.game_type,
        count(*) as total_prize_count,
        sum(case when p.prize_type in ('main', 'second') then 1 else 0 end) as tangible_prize_count,
        sum(case when p.prize_type = 'main' then 1 else 0 end) as main_prize_count,
        sum(case when p.prize_type = 'second' then 1 else 0 end) as second_prize_count,
        sum(case when p.prize_type = 'instant' then 1 else 0 end) as credit_prize_count,
        coalesce(sum(p.prize_value), 0) as gross_prize_value,
        coalesce(sum(case when p.prize_type in ('main', 'second') then p.prize_value else 0 end), 0) as tangible_prize_value,
        coalesce(sum(case when p.prize_type = 'main' then p.prize_value else 0 end), 0) as main_prize_value,
        coalesce(sum(case when p.prize_type = 'second' then p.prize_value else 0 end), 0) as second_prize_value,
        coalesce(sum(case when p.prize_type = 'instant' then p.prize_value else 0 end), 0) as credit_prize_value
    from prize_awards as p
    inner join contests as c
        on p.contest_sk = c.contest_sk
    inner join tenants as t
        on c.tenant_id = t.tenant_id
    group by 1, 2, 3, 4, 5

)

select * from award_metrics
