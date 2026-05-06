with 

source as (

    select * from {{ source('bronze', 'collections') }}

),

renamed as (

    select
        md5(collection_id) as collection_id,
        md5(user_id) as user_id,
        md5(game_id)as game_id,
        CASE 
            WHEN upper(LEFT(status, 1)) = 'O' THEN 'Owned'
            WHEN upper(LEFT(status, 1)) = 'P' THEN 'Played'
            WHEN upper(LEFT(status, 1)) = 'W' THEN 'Wishlist'
            WHEN upper(LEFT(status, 1)) = 'T' THEN 'Trading'
        END AS status,

        CASE
            WHEN LENGTH(SPLIT_PART(added_at, '-', 1)) = 4
              THEN TRY_TO_DATE(added_at, 'YYYY-MM-DD') 
                ELSE  TRY_TO_DATE(added_at, 'DD-MM-YYYY')
                  END AS added_at,
        coalesce(num_plays,0) as num_plays,
        _loaded_at

    from source

)

select * from renamed