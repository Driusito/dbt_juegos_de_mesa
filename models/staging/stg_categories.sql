with 

source as (

    select * from {{ source('bronze', 'categories') }}

),

renamed as (

    select distinct
        md5(category_id) as category_id,
        initcap(category_name) as name,
        coalesce(description,'No description') as Description,
        _loaded_at

    from source

)

select * from renamed