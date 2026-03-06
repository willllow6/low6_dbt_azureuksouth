with

source as (

    select *
    from {{ source('prizekings_comps','transactions') }}

),

renamed as (

    select

        ----------  ids
        id as transaction_id,
        user_id,
        raffle_id,
        promotion_id,
        user_promotion_id,
        metadata:competitionId::integer as competition_id,
        case 
            when raffle_id is not null
                then 'DRAW_' || raffle_id
            when competition_id is not null
                then 'STB_' || competition_id
            else null
        end as competition_sk,
        metadata:prizeId::string as prize_id,

        ---------- strings
        balance_type,
        metadata:source::string as transaction_source,
        transaction_type as transaction_direction,
        status as transaction_status,
        payment_provider,
        payment_reference,
        

        metadata as meta_data_json,
        

        ---------- numerics
        amount,

        ---------- booleans

        ---------- dates

        ---------- timestamps
        meta_data_json:externalPaymentData.paymentDate::timestamp_tz AS payment_processed_at,
        created_at,
        updated_at

    from source

)

select * from renamed