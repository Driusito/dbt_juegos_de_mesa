with 

source as (

    select * from {{ source('bronze', 'mechanics') }}

),

renamed as (

    select
        mechanic_id,
        mechanic_name,
        description,
        _loaded_at

    from source

)

select * from renamed