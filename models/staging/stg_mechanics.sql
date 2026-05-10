with

source as (

    select * from {{ source('bronze', 'mechanics') }}

),

renamed as (

    select
        mechanic_id,
        initcap(trim(mechanic_name))                    as mechanic_name,
        description,
        _loaded_at
    from source
    where {{ is_valid_id('mechanic_id', '^MEC-[0-9]{3}$') }}

),

filtered as (

    select *
    from renamed
    where mechanic_name is not null
    qualify row_number() over (
        partition by mechanic_id
        order by _loaded_at
    ) = 1

)

select * from filtered