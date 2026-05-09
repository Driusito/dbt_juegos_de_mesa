with 

source as (

    select * from {{ source('bronze', 'designers') }}

),

renamed as (

    select
        designer_id,
        name,
        nationality,
        birth_year

    from source

)

select * from renamed