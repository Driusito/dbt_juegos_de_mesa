{{ config(
    materialized     = 'incremental',
    unique_key       = 'review_sk',
    on_schema_change = 'sync_all_columns'
) }}

with stg_reviews as (

    select * from {{ ref('stg_reviews_incremental') }}

),

dim_game as (

    select * from {{ ref('dim_game') }}

),

dim_user as (

    select * from {{ ref('dim_user') }}

),

dim_date as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        md5(r.review_id)                             as review_sk,
        u.user_sk,
        g.game_sk,
        d.date_sk,
        case
            when r.rating > 10.0 then 10
            when r.rating < 0    then 0
            else r.rating
        end                                          as rating,
        coalesce(r.helpful_votes, 0)                 as helpful_votes,
        len(r.review_text)                           as review_length_chars,
        r.review_date,
        r._loaded_at

    from stg_reviews      r
    left join dim_game    g on r.game_id      = g.game_id
    left join dim_user    u on r.user_id      = u.user_id
                           and r.review_date >= u.valid_from
                           and r.review_date <  u.valid_to
    left join dim_date    d on r.review_date  = d.date

    where g.game_sk is not null
      and u.user_sk is not null
      and d.date_sk is not null

    {% if is_incremental() %}
        and r._loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}

)

select * from final