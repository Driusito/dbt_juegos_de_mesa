with 

source as (

    select * from {{ source('bronze', 'collections') }}

),

renamed as (

    select
        collection_id,
        user_id,
        game_id,
        status,
        added_at,
        num_plays

    from source

)

select * from renamed