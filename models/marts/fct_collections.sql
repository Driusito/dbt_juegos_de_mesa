with stg_collections as (
    select
        *,
        lower(trim(user_id)) as user_id_norm
    from {{ ref('stg_collections') }}
),

dim_game as (
    select * from {{ ref('dim_game') }}
),

dim_date as (
    select * from {{ ref('dim_date') }}
),

final as (
    select
        md5(c.collection_id) as collection_sk,
        md5(c.user_id_norm) as user_sk,
        c.user_id_norm as user_id,
        g.game_sk,
        d.date_sk,
        c.status,
        coalesce(c.num_plays, 0) as num_plays,
        c.added_at
    from stg_collections c
    left join dim_game g
        on c.game_id = g.game_id
    left join dim_date d
        on c.added_at = d.date
    where g.game_sk is not null
      and d.date_sk is not null
)

select * from final
