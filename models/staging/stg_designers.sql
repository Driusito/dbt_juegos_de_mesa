with

source as (

    select * from {{ source('bronze', 'designers') }}

),

renamed as (

    select
        designer_id,
        initcap(trim(name))         as name,
        upper(trim(nationality))    as nationality,
        birth_year,
        _loaded_at
    from source
    where {{ is_valid_id('designer_id', '^DES-[0-9]{3}$') }}

),

filtered as (

    select *
    from renamed
    where name is not null
    qualify row_number() over (
        partition by designer_id
        order by _loaded_at
    ) = 1

)

select * from filtered