with

source as (

    select * from {{ source('bronze', 'publishers') }}

),

renamed as (

    select
        publisher_id,
        name,
        upper(country) as country,
        coalesce(founded_year,9999),
        is_active
    from source
    where publisher_id is not null
    qualify row_number() over (
        partition by publisher_id
        order by _loaded_at
    ) = 1

)

select * from renamed