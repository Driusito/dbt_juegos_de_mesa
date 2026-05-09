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
        added_at,
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