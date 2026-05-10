with

source as (

    select * from {{ source('bronze', 'designers') }}

),

renamed as (

    select
        designer_id,
        initcap(name) as name,
        initcap(nationality) as nationality,
        coalesce(birth_year,9999) as birth_year
    from source
    where designer_id is not null
    qualify row_number() over (
        partition by designer_id
        order by _loaded_at
    ) = 1

)

select * from renamed