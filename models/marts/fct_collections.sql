with stg_collections as (

    select * from {{ ref('stg_collections') }}

),

dim_game as (

    select * from {{ ref('dim_game') }}

),

dim_user as (

    select * from {{ ref('dim_user') }}
    where is_current = true

),

dim_date as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        md5(c.collection_id)                         as collection_sk,
        u.user_sk,
        g.game_sk,
        d.date_sk,
        c.status,
        coalesce(c.num_plays, 0)                     as num_plays,
        c.added_at

    from stg_collections  c
    left join dim_game    g on c.game_id  = g.game_id
    left join dim_user    u on c.user_id  = u.user_id
    left join dim_date    d on c.added_at = d.date

    where g.game_sk is not null
      and u.user_sk is not null
      and d.date_sk is not null

)

select * from final