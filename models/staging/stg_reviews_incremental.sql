{{ config(
    materialized  = 'incremental',
    unique_key    = 'review_id',
    on_schema_change = 'sync_all_columns'
) }}

with source as (

    select * from {{ source('bronze', 'reviews') }}

),

renamed_casted as (

    select
        review_id,
        user_id,
        game_id,
        rating,
        review_text,
        review_date,
        helpful_votes,
        _loaded_at

    from source

    where review_id is not null

    {% if is_incremental() %}
        and _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}

)

select * from renamed_casted