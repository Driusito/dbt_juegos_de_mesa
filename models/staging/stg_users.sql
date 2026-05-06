with 

source as (

    select * from {{ source('bronze', 'users') }}

),

renamed as (

    select
        user_id,
        username,
        email,
        country,
        registration_date,
        user_type,
        _loaded_at

    from source

)

select * from renamed