with

source as (

    select * from {{ source('bronze', 'users') }}

),

renamed as (

    select
        user_id,
        lower(trim(username))                       as username,
        case
            when email like '%@%.%'
            and length(trim(email)) > 6
            and email not like '%[at]%'
            then lower(trim(email))
            else null
        end                                         as email,
        upper(trim(country))                        as country,
        registration_date,
        case upper(trim(user_type))
            when 'CASUAL'       then 'casual'
            when 'ENTHUSIAST'   then 'enthusiast'
            when 'COLLECTOR'    then 'collector'
            else null
        end                                         as user_type,
        _loaded_at
    from source
    where {{ is_valid_id('user_id', '^USR-[0-9]{4}$') }}

),

filtered as (

    select *
    from renamed
    where user_type is not null
    qualify row_number() over (
        partition by user_id
        order by _loaded_at desc
    ) = 1

)

select * from filtered