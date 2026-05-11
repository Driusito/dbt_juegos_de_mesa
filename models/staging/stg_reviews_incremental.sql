{{ config(
    materialized     = 'incremental',
    unique_key       = 'review_id',
    on_schema_change = 'sync_all_columns'
) }}

with source as (

    select * from {{ source('bronze', 'reviews') }}

),

renamed as (

    select
        review_id,
        user_id,
        game_id,
        coalesce(rating, 0.0)                   as rating,
        coalesce(trim(review_text), 'No text')  as review_text,
        review_date,
        coalesce(helpful_votes, 0)              as helpful_votes,
        _loaded_at
    from source
    where {{ is_valid_id('review_id', '^REV-[0-9]{5}$') }}
      and {{ is_valid_id('user_id',   '^USR-[0-9]{4}$') }}
      and {{ is_valid_id('game_id',   '^GAME-[0-9]{4}$') }}

    {% if is_incremental() %}
        and _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}

    qualify row_number() over (
        partition by review_id
        order by _loaded_at desc
    ) = 1

),

filtered as (

    select *
    from renamed
    where review_date is not null

)

select * from filtered