with 

source as (

    select * from {{ source('bronze', 'categories') }}

),

renamed as (

    select distinct
        md5(category_id) as category_id,
        category_name,
        description,
        _loaded_at

    from source

)

select * from renamed