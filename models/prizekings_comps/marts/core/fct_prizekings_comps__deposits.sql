
with

deposits as (

    select 
        transaction_id,
        user_id,
        transaction_status,
        payment_provider,
        payment_reference,
        amount,
        meta_data_json,
        payment_processed_at,
        created_at as transaction_created_at,
        updated_at as transaction_updated_at
    from {{ ref('stg_prizekings_comps__transactions') }}
    where payment_reference is not null
    and transaction_direction = 'incoming'
    and balance_type = 'deposit'
    and transaction_status = 'completed'

)

select
    *,
    row_number() over (partition by user_id order by payment_processed_at) as user_deposit_number
from deposits

