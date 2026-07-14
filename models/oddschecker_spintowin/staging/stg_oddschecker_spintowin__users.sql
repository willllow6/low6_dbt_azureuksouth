with

source as (

    select *
    from {{ source('oddschecker_spintowin', 'users') }}

),

renamed as (

    select

        ---------- ids
        id as user_id,

        ---------- strings
        'oddschecker' as client_id,
        'oddschecker' as tenant_id,
        'oddschecker' as tenant_name,
        'instant_win' as game_type,
        oddschecker_id as external_user_id,
        email,
        oc_plus_reward_status,
        oc_plus_reward_variant,

        ---------- numerics
        free_spins,
        spins_consumed,

        ---------- booleans
        case
            when locked_at is null or unlocked_at is not null
                then true
            else false
        end as is_active,

        ---------- timestamps
        oc_plus_reward_granted_at,
        locked_at,
        unlocked_at,
        created_at

    from source

)

select * from renamed
