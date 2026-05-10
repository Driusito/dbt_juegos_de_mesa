with

source as (

    select * from {{ source('bronze', 'categories') }}

),

renamed as (

    select
        category_id,
        initcap(category_name)as category_name,
        coalesce(description,'No description') as description
    from source
    where category_id is not null
    qualify row_number() over (
        partition by category_id
        order by _loaded_at
    ) = 1

)

select * from renamed