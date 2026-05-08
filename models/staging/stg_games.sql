with 

source as (

    select * from {{ source('bronze', 'games') }}

),

renamed as (

    select
        game_id,
        title,
        year_published,
        language_dependence,
        min_players,
        max_players,
        min_playtime,
        max_playtime,
        min_age,
        complexity_weight,
        publisher_id,
        designer_id,
        bgg_rank,        
        _loaded_at

    from source

)

select * from renamed