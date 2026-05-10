with

source as (

    select * from {{ source('bronze', 'collections') }}

),

renamed as (

    select
        collection_id,
        user_id,
        game_id,
        case upper(trim(status))
            when 'OWNED'      then 'Owned'
            when 'PLAYED'     then 'Played'
            when 'WISHLIST'   then 'Wishlist'
            when 'WISH LIST'  then 'Wishlist'
            when 'TRADING'    then 'Trading'
            else null
        end                                         as status,
        case
            when length(split_part(added_at, '-', 1)) = 4
                then try_to_date(added_at, 'YYYY-MM-DD')
            else try_to_date(added_at, 'DD-MM-YYYY')
        end                                         as added_at,
                                                    num_plays,
                                                    _loaded_at
    from source
    where {{ is_valid_id('collection_id', '^COL-[0-9]{5}$') }}
      and {{ is_valid_id('user_id',       '^USR-[0-9]{4}$') }}
      and {{ is_valid_id('game_id',       '^GAME-[0-9]{4}$') }}

),

filtered as (

    select *
    from renamed
    where status   is not null
      and added_at is not null
    qualify row_number() over (
        partition by collection_id
        order by _loaded_at desc
    ) = 1

)

select * from filtered