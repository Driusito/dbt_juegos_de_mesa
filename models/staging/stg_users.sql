with

source as (

    select * from {{ source('bronze', 'users') }}

),

renamed as (

    select
        user_id,
        username,
        email,
        upper(country) as country,
        registration_date,
        initcap(user_type)as user_type
    from source
    where user_id is not null
    and email is not null
    qualify row_number() over (
        partition by user_id
        order by _loaded_at desc
    ) = 1

)

select * from renamed