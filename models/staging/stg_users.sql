with

source as (

    select * from {{ source('bronze', 'users') }}

),

cleaned as (

    select
        user_id,
        lower(trim(username))                           as username,

        case
            when email like '%@%.%'
            then lower(trim(email))
            else null
        end                                             as email,

        upper(trim(country))                            as country,

        try_cast(registration_date as date)             as registration_date,

        case
            when lower(trim(user_type)) in ('casual')                       then 'Casual'
            when lower(trim(user_type)) in ('enthusiast')                   then 'Enthusiast'
            when lower(trim(user_type)) in ('collector')                    then 'Collector'
            else null
        end                                             as user_type,

        _loaded_at

    from source

    where user_id is not null

),

filtered as (

    select *
    from cleaned
    where user_type is not null
      and registration_date is not null

    qualify row_number() over (
        partition by user_id
        order by _loaded_at desc
    ) = 1

)

select * from filtered