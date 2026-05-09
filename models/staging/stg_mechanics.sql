with

source as (

    select * from {{ source('bronze', 'mechanics') }}

),

renamed as (

    select
        mechanic_id,
        initcap(mechanic_name) as mechanic_name,
        coalesce(description, "No description") as description
    from source
    where mechanic_id is not null
    qualify row_number() over (
        partition by mechanic_id
        order by _loaded_at
    ) = 1

)

select * from renamed