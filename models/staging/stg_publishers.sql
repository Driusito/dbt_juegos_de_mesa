with

source as (

    select * from {{ source('bronze', 'publishers') }}

),

renamed as (

    select
        publisher_id,
        initcap(trim(name))                         as name,
        upper(trim(country))                        as country,
        founded_year,
        is_active,
        _loaded_at
    from source
    where {{ is_valid_id('publisher_id', '^PUB-[0-9]{3}$') }}

),

filtered as (

    select *
    from renamed
    where name is not null
    qualify row_number() over (
        partition by publisher_id
        order by _loaded_at
    ) = 1

)

select * from filtered