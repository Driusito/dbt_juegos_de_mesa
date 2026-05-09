with 

source as (

    select * from {{ source('bronze', 'game_mechanics') }}

),

renamed as (

    select
        game_id,
        mechanic_id

    from source

)

select * from renamed