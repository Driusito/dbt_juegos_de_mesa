with

source as (

    select * from {{ source('bronze', 'collections') }}

),

renamed as (

    select
        collection_id,
        user_id,
        game_id,
        initcap(status) as status,
        CASE
            WHEN LENGTH(SPLIT_PART(added_at, '-', 1)) = 4
              THEN TRY_TO_DATE(added_at, 'YYYY-MM-DD') 
                ELSE  TRY_TO_DATE(added_at, 'DD-MM-YYYY')
                  END AS added_at ,
        coalesce(num_plays,0) as num_plays
    from source
    where collection_id is not null
      and user_id is not null
      and game_id is not null
    qualify row_number() over (
        partition by collection_id
        order by _loaded_at desc
    ) = 1

)

select * from renamed