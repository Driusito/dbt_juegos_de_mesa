with 

source as (

    select * from {{ source('bronze', 'mechanics') }}

),

renamed as (

    select
        mechanic_id,
        initcap(mechanic_name) as mechanic_name,
        coalesce(description,'No description') as description,
        _loaded_at

    from source

)

select * from renamed