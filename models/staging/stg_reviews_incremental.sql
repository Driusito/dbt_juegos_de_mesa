{{ config(
    materialized     = 'incremental',
    unique_key       = 'review_id',
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
        coalesce(rating,0.0) as rating,
        coalesce(review_text,"No text") as review_text,
        review_date,
        coalesce(helpful_votes,0)as helpful_votes,
        _loaded_at
    from source
    where review_id is not null
      and user_id   is not null
      and game_id   is not null

    {% if is_incremental() %}
        and _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}

)

select * from renamed_casted