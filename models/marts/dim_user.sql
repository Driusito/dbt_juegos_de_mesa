with base as (

    select distinct
        regexp_replace(lower(trim(user_id)), '[^a-z0-9-]', '') as user_id,
        username,
        email,
        country,
        user_type,
        _loaded_at
    from {{ ref('stg_users') }}

),

snapshot as (

    select
        regexp_replace(lower(trim(user_id)), '[^a-z0-9-]', '') as user_id,
        username,
        email,
        country,
        user_type,
        dbt_valid_from
    from {{ ref('user_snapshot_check') }}

),

latest_snapshot as (

    select *
    from snapshot
    qualify row_number() over (
        partition by user_id
        order by dbt_valid_from desc
    ) = 1

),

enriched as (

    select
        md5(b.user_id) as user_sk,
        b.user_id,
        coalesce(s.username, 'unknown') as username,
        case
            when s.email is null or trim(lower(s.email)) in ('null','n/a','na','none','')
            then null
            else lower(trim(s.email))
        end as email,
        coalesce(s.country, 'XX') as country_code,
        c.country_name,
        c.continent,
        coalesce(s.user_type, 'casual') as user_type,
        coalesce(s.dbt_valid_from, current_date()) as valid_from,
        true as is_current
    from base b
    left join latest_snapshot s
        on b.user_id = s.user_id
    left join {{ ref('country_codes') }} c
        on s.country = c.country_code

),

missing_users as (

    -- Usuarios que aparecen en FCT pero NO existen en base
    select distinct user_id
    from (
        select regexp_replace(lower(trim(user_id)), '[^a-z0-9-]', '') as user_id
        from {{ ref('fct_reviews') }}

        union all

        select regexp_replace(lower(trim(user_id)), '[^a-z0-9-]', '') as user_id
        from {{ ref('fct_collections') }}
    ) f
    where user_id not in (select user_id from base)

),

dummy_rows as (

    select
        md5(user_id) as user_sk,
        user_id,
        'unknown' as username,
        null as email,
        'XX' as country_code,
        'Unknown' as country_name,
        'Unknown' as continent,
        'casual' as user_type,
        current_date() as valid_from,
        true as is_current
    from missing_users

)

select * from enriched
union all
select * from dummy_rows
