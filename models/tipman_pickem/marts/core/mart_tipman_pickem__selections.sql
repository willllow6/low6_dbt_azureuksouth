with

selections as (

    select *
    from {{ ref('stg_tipman_pickem__selections') }}

),

questions as (

    select
        question_id,
        contest_id,
        question_text,
        question_type,
        correct_value as question_correct_value,
        points as question_points
    from {{ ref('stg_tipman_pickem__questions') }}

),

options as (

    select
        option_id,
        question_id,
        option_text,
        is_correct
    from {{ ref('stg_tipman_pickem__options') }}

),

users as (

    select
        user_id,
        username,
        email,
        external_user_id
    from {{ ref('dim_tipman_pickem__users') }}

),

contests as (

    select
        contest_id,
        tenant_id,
        tenant_name,
        contest_name,
        contest_status
    from {{ ref('dim_tipman_pickem__contests') }}

),

joined as (

    select
        selections.selection_id,
        selections.entry_id,
        selections.user_id,
        selections.contest_id,
        selections.question_id,
        selections.option_id,
        selections.client_id,
        contests.tenant_id,
        contests.tenant_name,
        selections.game_type,

        users.username,
        users.email,
        users.external_user_id,

        contests.contest_name,
        contests.contest_status,

        questions.question_text,
        questions.question_type,
        options.option_text as selected_option_text,
        options.is_correct as is_selection_correct,

        selections.tiebreaker_prediction,
        questions.question_correct_value as tiebreaker_outcome,
        selections.points,

        selections.selected_at,
        convert_timezone('UTC', '{{ var("local_timezone") }}', selections.selected_at) as selected_at_local,
        cast(convert_timezone('UTC', '{{ var("local_timezone") }}', selections.selected_at) as date) as selection_date_local

    from selections
    left join users
        on selections.user_id = users.user_id
    left join contests
        on selections.contest_id = contests.contest_id
    left join questions
        on selections.question_id = questions.question_id
        and selections.contest_id = questions.contest_id
    left join options
        on selections.option_id = options.option_id
        and selections.question_id = options.question_id

)

select * from joined
