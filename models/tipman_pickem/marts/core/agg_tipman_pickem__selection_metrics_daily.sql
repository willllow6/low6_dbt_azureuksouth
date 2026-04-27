with

selections as (

    select
        selection_id,
        user_id,
        contest_id,
        client_id,
        game_type,
        option_id,
        points,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', selected_at) as date) as selection_date
    from {{ ref('stg_tipman_pickem__selections') }}

),

options as (

    select
        option_id,
        question_id,
        is_correct
    from {{ ref('stg_tipman_pickem__options') }}

),

contests as (

    select
        contest_id,
        tenant_id,
        tenant_name
    from {{ ref('dim_tipman_pickem__contests') }}

),

selections_with_correctness as (

    select
        selections.selection_id,
        selections.contest_id,
        selections.client_id,
        selections.game_type,
        selections.selection_date,
        options.is_correct
    from selections
    left join options
        on selections.option_id = options.option_id

),

daily as (

    select
        swc.selection_date as date_day,
        swc.client_id,
        contests.tenant_id,
        contests.tenant_name,
        swc.game_type,
        swc.contest_id,
        count(swc.selection_id) as total_selections,
        count(case when swc.is_correct = true then swc.selection_id end) as correct_selections,
        round(
            count(case when swc.is_correct = true then swc.selection_id end)
            / nullif(count(case when swc.is_correct is not null then swc.selection_id end), 0),
            4
        ) as accuracy_rate
    from selections_with_correctness as swc
    left join contests
        on swc.contest_id = contests.contest_id
    group by
        swc.selection_date,
        swc.client_id,
        contests.tenant_id,
        contests.tenant_name,
        swc.game_type,
        swc.contest_id

)

select * from daily
