with

source as (

    select * from {{ source('bronze', 'games') }}

),

renamed as (

    select
        game_id,
        initcap(trim(title))                        as title,
        year_published,
        case
            when upper(trim(language_dependence)) in ('ENG', 'ENGLISH') then 'ENG'
            when upper(trim(language_dependence)) in ('LOW')            then 'LOW'
            when upper(trim(language_dependence)) in ('NONE')           then 'NONE'
            else null
        end                                         as language_dependence,
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
    where {{ is_valid_id('game_id',      '^GAME-[0-9]{4}$') }}
      and {{ is_valid_id('publisher_id', '^PUB-[0-9]{3}$') }}
      and {{ is_valid_id('designer_id',  '^DES-[0-9]{3}$') }}

),

filtered as (

    select *
    from renamed
    where title               is not null
    qualify row_number() over (
        partition by game_id
        order by _loaded_at desc
    ) = 1

)

select * from filtered