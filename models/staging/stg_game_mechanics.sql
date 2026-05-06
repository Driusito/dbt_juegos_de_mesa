with

source as (

    select game_id, mechanics
    from {{ source('bronze', 'games') }}

),

exploded as (

    select
        game_id,
        trim(m.value::string) as mechanic_name
    from source,
    lateral split_to_table(mechanics, ',') m
    where game_id is not null
      and trim(m.value::string) != ''
      and trim(m.value::string) not in ('N/A', 'TBD', 'Unknown')

),

joined as (

    select
        e.game_id,
        m.mechanic_id
    from exploded e
    inner join {{ ref('stg_mechanics') }} m
        on lower(trim(e.mechanic_name)) = lower(trim(m.mechanic_name))

    qualify row_number() over (
        partition by e.game_id, m.mechanic_id
        order by e.game_id
    ) = 1

)

select * from joined