with stg_games as (

    select * from {{ ref('stg_games') }}

),

stg_publishers as (

    select * from {{ ref('stg_publishers') }}

),

stg_designers as (

    select * from {{ ref('stg_designers') }}

),

final as (

    select
        md5(g.game_id)                                   as game_sk,
        g.game_id,
        g.title,
        g.year_published,
        g.language_dependence,
        g.min_players,
        g.max_players,
        g.min_playtime,
        g.max_playtime,
        g.min_age,
        g.complexity_weight,
        g.bgg_rank,

        round((g.min_playtime + g.max_playtime) / 2, 0) as avg_playtime,

        case
            when g.complexity_weight < 2.0 then 'Light'
            when g.complexity_weight < 3.0 then 'Medium-Light'
            when g.complexity_weight < 4.0 then 'Medium-Heavy'
            else                                'Heavy'
        end                                              as complexity_bucket,

        p.name                                           as publisher_name,
        p.country                                        as publisher_country,
        d.name                                           as designer_name,
        d.nationality                                    as designer_nationality

    from stg_games        g
    left join stg_publishers p on g.publisher_id = p.publisher_id
    left join stg_designers  d on g.designer_id  = d.designer_id

)

select * from final