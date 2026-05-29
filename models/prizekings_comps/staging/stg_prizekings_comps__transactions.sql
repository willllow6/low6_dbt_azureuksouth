with

source as (

    select *
    from {{ source('prizekings_comps','transactions') }}

),

meta as (

    select
        *,
        metadata:competitionId::integer                        as _competition_id,
        metadata:arcadeCompetitionId::integer                  as _arcade_competition_id,
        metadata:prizeId::string                               as _prize_id,
        metadata:source::string                                as _source,
        metadata:ticketId                                      as _ticket_id,
        metadata:entryId::integer                              as _entry_id,
        metadata:quantity::integer                             as _quantity,
        metadata:picksCount::integer                           as _picks_count,
        metadata:ticketsType                                   as _tickets_type,
        metadata:paidEntries::integer                          as _paid_entries,
        metadata:freeEntries::integer                          as _free_entries,
        metadata:externalPaymentData.paymentDate::timestamp_tz as _payment_date
    from source

),

renamed as (

    select

        ----------  ids
        id as transaction_id,
        user_id,
        raffle_id,
        promotion_id,
        user_promotion_id,
        case
            when _source = 'arcade_entry_balance' then _arcade_competition_id
            else _competition_id
        end as contest_id,
        case
            when _source = 'arcade_entry_balance' and _arcade_competition_id is not null
                then 'ARC_' || _arcade_competition_id
            when raffle_id is not null
                then 'DRAW_' || raffle_id
            when _competition_id is not null
                then 'STB_' || _competition_id
            else null
        end as contest_sk,
        _prize_id as prize_id,
        case
            when _source = 'arcade_entry_balance' then null
            when raffle_id is not null
                then 'DRAW_' || _prize_id
            when _competition_id is not null
                then 'STB_' || _prize_id
            else null
        end as prize_sk,
        case
            when _source = 'arcade_entry_balance' then null
            when raffle_id is not null
                then 'DRAW_' || _ticket_id
            when _competition_id is not null
                then 'STB_' || _entry_id
            else null
        end as entry_sk,

        ---------- strings
        'prizekings' as client_id,
        'prize_competition' as game_type,
        balance_type,
        _source as transaction_source,
        transaction_type as transaction_direction,
        status as transaction_status,

        payment_provider,
        payment_reference,


        metadata as meta_data_json,


        ---------- numerics
        case
            when _source = 'ticket_purchase_balance'
                then _quantity
            when _source = 'spot_the_ball_entry_balance'
                then _picks_count
            else null
        end as entries,
        case
            when _source = 'ticket_purchase_balance' and _tickets_type = 'paid'
                then _quantity
            when _source = 'ticket_purchase_balance' and _tickets_type = 'free'
                then 0
            when _source = 'spot_the_ball_entry_balance' and _paid_entries is not null
                then _paid_entries
            when _source = 'spot_the_ball_entry_balance' and _paid_entries is null
                then _picks_count
            else null
        end as paid_entries,
        case
            when _source = 'ticket_purchase_balance' and _tickets_type = 'free'
                then _quantity
            when _source = 'ticket_purchase_balance' and _tickets_type = 'paid'
                then 0
            when _source = 'spot_the_ball_entry_balance' and _free_entries is not null
                then _free_entries
            when _source = 'spot_the_ball_entry_balance' and _free_entries is null
                then 0
            else null
        end as free_entries,
        amount,

        ---------- booleans

        ---------- dates

        ---------- timestamps
        _payment_date as payment_processed_at,
        created_at,
        updated_at

    from meta

)

select * from renamed
