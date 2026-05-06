with

source as (

    select game_id, categories
    from {{ source('bronze', 'games') }}

),

exploded as (

    select
        game_id,
        trim(c.value::string) as category_name
    from source,
    lateral split_to_table(categories, ',') c
    where game_id is not null
      and trim(c.value::string) != ''
      and trim(c.value::string) not in ('N/A', 'TBD', 'Unknown')

),

joined as (

    select
        e.game_id,
        c.category_id
    from exploded e
    inner join {{ ref('stg_categories') }} c
        on lower(trim(e.category_name)) = lower(trim(c.name))

    qualify row_number() over (
        partition by e.game_id, c.category_id
        order by e.game_id
    ) = 1

)

select * from joined