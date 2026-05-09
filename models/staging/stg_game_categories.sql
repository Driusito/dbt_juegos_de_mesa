with 

source as (

    select * from {{ source('bronze', 'game_categories') }}

),

renamed as (

    select
        game_id,
        category_id

    from source

)

select * from renamed