with 

source as (

    select * from {{ source('bronze', 'mechanics') }}

),

renamed as (

    select
        mechanic_id,
        mechanic_name,
        description

    from source

)

select * from renamed