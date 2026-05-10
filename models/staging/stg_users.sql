with

source as (

    select * from {{ source('bronze', 'users') }}

),

renamed as (

    select
        user_id,
        username,
        case
            when email like '%@%.%'
            and length(trim(email)) > 6
            and email not like '%[at]%'
            then lower(trim(email))
        end                          as email,
        upper(country)               as country,
        registration_date,
        initcap(user_type)           as user_type,
        _loaded_at
    from source
    where user_id is not null

),

filtered as (

    select *
    from renamed
    where email is not null          
    qualify row_number() over (
        partition by user_id
        order by _loaded_at desc
    ) = 1

)

select * from filtered