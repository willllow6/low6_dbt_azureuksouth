with

source as (

    select *
    from {{ source('gaming1', 'pickems') }}

),

renamed as (

    select

        ----------  ids
        id::varchar as contest_id,
        tenant_id::varchar as tenant_id,

        ---------- strings
        'gaming1' as client_id,
        'pickem' as game_type,
        title_en as contest_name,
        pickem_status as contest_status,
        prize_text_en as prize_text,
        sport,

        ---------- booleans
        scored as is_scored,
        -- TODO: confirm exact pickem_status values with gaming1 source team
        pickem_status not in ('DRAFT', 'CLOSED', 'COMPLETED', 'CANCELLED') as is_active,

        ---------- timestamps
        open_pickem_utc as opens_at,
        start_utc as starts_at,
        created_at,
        updated_at

    from source

)

select * from renamed
