with 

source as (

    select * from {{ source('bronze', 'game_categories') }}

),

renamed as (

    select
        game_id,
        category_id,
        _loaded_at

    from source

)

select * from renamed