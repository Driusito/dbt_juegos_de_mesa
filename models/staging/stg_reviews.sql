with 

source as (

    select * from {{ source('bronze', 'reviews') }}

),

renamed as (

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

)

select * from renamed