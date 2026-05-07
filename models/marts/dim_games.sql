with

source as (

    select * from {{ ref("stg_games") }}

),

cleaned as (

    select
        game_id,
        initcap(trim(title))                                as title,
        year_published,

        case
            when upper(trim(language_dependence)) in ('ENG', 'ENGLISH') then 'ENG'
            when upper(trim(language_dependence)) in ('LOW')            then 'LOW'
            when upper(trim(language_dependence)) in ('NONE')           then 'NONE'
            else null
        end                                                 as language_dependence,

        coalesce(min_players, 1)        as min_players,
        coalesce(max_players, 1)        as max_players,
        coalesce(min_playtime, 0)       as min_playtime,
        coalesce(max_playtime, 0)       as max_playtime,
        coalesce(min_age, 3)            as min_age,
        complexity_weight,
        publisher_id,
        designer_id,
        bgg_rank,
        _loaded_at

    from source

    where game_id is not null

),

filtered as (

    select *
    from cleaned
    where min_players <= max_players
      and complexity_weight between 1.0 and 5.0
      and language_dependence is not null
      and max_players <=10

    qualify row_number() over (
        partition by game_id
        order by _loaded_at desc
    ) = 1

),

final as (

    select
        *,
        round((min_playtime + max_playtime) / 2, 0)     as avg_playtime,

        case
            when complexity_weight < 2.0 then 'Light'
            when complexity_weight < 3.0 then 'Medium-Light'
            when complexity_weight < 4.0 then 'Medium-Heavy'
            else                              'Heavy'
        end                                             as complexity_bucket

    from filtered

)

select * from final