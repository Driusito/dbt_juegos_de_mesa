with 

source as (

    select * from {{ source('bronze', 'categories') }}

),

renamed as (

    select 
        category_id,
        category_name,
        description

    from source

)

select * from renamed