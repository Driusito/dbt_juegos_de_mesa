with stg_games as (

    select * from {{ ref('stg_games') }}

),

stg_publishers as (

    select * from {{ ref('stg_publishers') }}

),

stg_designers as (

    select * from {{ ref('stg_designers') }}

),

country_codes as (

    select * from {{ ref('country_codes') }}

),

final as (

    select
        md5(g.game_id)                                   as game_sk,
        g.game_id,
        g.title,
        g.year_published,
        initcap(g.language_dependence)                   as language_dependence,
        coalesce(g.min_players, 1)                       as min_players,
        coalesce(g.max_players,100)                      as max_players,                     
        coalesce(g.min_playtime, 1)                      as min_playtime,
        g.max_playtime,
        coalesce(g.min_age, 3)                           as min_age,
        coalesce(g.complexity_weight,1)                  as complexity_weight,                
        g.bgg_rank,

        round((g.min_playtime + g.max_playtime) / 2, 0) as avg_playtime,

        case
            when g.complexity_weight < 2.0 then 'Light'
            when g.complexity_weight < 3.0 then 'Medium-Light'
            when g.complexity_weight < 4.0 then 'Medium-Heavy'
            else                                'Heavy'
        end                                              as complexity_bucket,

        p.name                                           as publisher_name,
        p.country                                        as publisher_country_code,
        cp.country_name                                  as publisher_country_name,
        cp.continent                                     as publisher_continent,

        d.name                                           as designer_name,
        d.nationality                                    as designer_nationality_code,
        cd.country_name                                  as designer_country_name,
        cd.continent                                     as designer_continent

    from stg_games            g
    left join stg_publishers  p  on g.publisher_id = p.publisher_id
    left join stg_designers   d  on g.designer_id  = d.designer_id
    left join country_codes   cp on p.country      = cp.country_code
    left join country_codes   cd on d.nationality  = cd.country_code

)

select * from final