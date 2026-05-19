
with stg_reviews as (
    select
        *,
        lower(trim(user_id)) as user_id_norm
    from {{ ref('stg_reviews_incremental') }}
),

dim_game as (
    select * from {{ ref('dim_game') }}
),

dim_date as (
    select * from {{ ref('dim_date') }}
),

final as (
    select
        md5(r.review_id) as review_sk,
        md5(r.user_id_norm) as user_sk,
        r.user_id_norm as user_id,
        g.game_sk,
        d.date_sk,
        case
            when r.rating > 10.0 then 10
            when r.rating < 0    then 0
            else r.rating
        end as rating,
        coalesce(r.helpful_votes, 0) as helpful_votes,
        len(r.review_text) as review_length_chars,
        r.review_date,
        r._loaded_at
    from stg_reviews r
    left join dim_game g
        on r.game_id = g.game_id
    left join dim_date d
        on r.review_date = d.date
    where g.game_sk is not null
      and d.date_sk is not null

   
)

select * from final
