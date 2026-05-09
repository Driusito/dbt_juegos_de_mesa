with

source as (

    select * from {{ source('bronze', 'game_categories') }}

),

renamed as (

    select
        game_id,
        category_id
    from source
    where game_id is not null
      and category_id is not null
    qualify row_number() over (
        partition by game_id, category_id
        order by _loaded_at
    ) = 1

)

select * from renamed