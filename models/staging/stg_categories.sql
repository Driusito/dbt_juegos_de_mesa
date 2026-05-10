with

source as (

    select * from {{ source('bronze', 'categories') }}

),

renamed as (

    select
        category_id,
        initcap(trim(category_name))                    as category_name,
        description,
        _loaded_at
    from source
    where {{ is_valid_id('category_id', '^CAT-[0-9]{3}$') }}

),

filtered as (

    select *
    from renamed
    where category_name is not null
    qualify row_number() over (
        partition by category_id
        order by _loaded_at
    ) = 1

)

select * from filtered