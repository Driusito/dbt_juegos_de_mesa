with 

source as (

    select * from {{ source('bronze', 'publishers') }}

),

renamed as (

    select
        publisher_id,
        name,
        country,
        founded_year,
        is_active

    from source

)

select * from renamed