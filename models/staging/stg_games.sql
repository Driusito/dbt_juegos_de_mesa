with

source as (

    select * from {{ source('bronze', 'games') }}

),

renamed as (

    select
        game_id,
        initcap(title) as title,
        year_published,
        upper(language_dependence) as language_dependence,
        coalesce(min_players,1) as min_players,
        max_players,
        coalesce(min_playtime,1) as min_playtime,
        max_playtime,
        coalesce(min_age,3) as min_age,
        coalesce(complexity_weight,1.0) as complexity_weight,
        publisher_id,
        designer_id,
        bgg_rank
    from source
    where game_id is not null
    qualify row_number() over (
        partition by game_id
        order by _loaded_at desc
    ) = 1

)

select * from renamed