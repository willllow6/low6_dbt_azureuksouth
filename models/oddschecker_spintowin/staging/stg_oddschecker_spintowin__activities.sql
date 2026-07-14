with

source as (

    select *
    from {{ source('oddschecker_spintowin', 'activities') }}

),

renamed as (

    select

        ---------- ids
        id as activity_id,
        user_id,
        prize_tier_id,

        ---------- strings
        'oddschecker' as client_id,
        'oddschecker' as tenant_id,
        'oddschecker' as tenant_name,
        'instant_win' as game_type,
        feedback,

        ---------- booleans
        is_claimed,
        feedback not in ('Trivia answered incorrectly', 'No matching symbols') as is_winner,

        ---------- prize derivations
        case
            when feedback = 'OC+ Premium Subscription' then 'oc_plus'
            when feedback not in ('Trivia answered incorrectly', 'No matching symbols') then 'voucher'
            else null
        end as prize_type,
        case
            when feedback not in ('Trivia answered incorrectly', 'No matching symbols') then feedback
            else null
        end as prize_name,

        ---------- timestamps
        created_at,
        updated_at

    from source

)

select * from renamed
