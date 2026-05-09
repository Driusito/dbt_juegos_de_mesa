with 

source as (

    select * from {{ source('bronze', 'categories') }}

),

renamed as (

    select 
        category_id,
        name,
        description

    from source

)

select * from renamed