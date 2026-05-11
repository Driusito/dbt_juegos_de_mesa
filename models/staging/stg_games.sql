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
            else 'NONE'
        end                                         as language_dependence,
        min_players,
        max_players,
        min_playtime,
        max_playtime,
        min_age,
        complexity_weight,
        case
            when publisher_id is not null
             and upper(trim(publisher_id)) not in ('NULL', 'N/A', 'NA', 'NONE', '')
             and regexp_like(publisher_id, '^PUB-[0-9]{3}$')
            then publisher_id
            else null
        end                                         as publisher_id,
        case
            when designer_id is not null
             and upper(trim(designer_id)) not in ('NULL', 'N/A', 'NA', 'NONE', '')
             and regexp_like(designer_id, '^DES-[0-9]{3}$')
            then designer_id
            else null
        end                                         as designer_id,
        bgg_rank,
        _loaded_at
    from source
    where {{ is_valid_id('game_id', '^GAME-[0-9]{4}$') }}

),

filtered as (

    select *
    from renamed
    where title is not null
    qualify row_number() over (
        partition by game_id
        order by _loaded_at desc
    ) = 1

)

select * from filtered