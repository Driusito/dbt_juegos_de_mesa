select
    s.dbt_scd_id                                     as user_sk,
    s.user_id,
    s.username,
    s.email,
    s.country                                        as country_code,
    c.country_name,
    c.continent,
    lower(trim(s.user_type)) as user_type,
    s.dbt_valid_from                                 as valid_from,
    coalesce(s.dbt_valid_to, '9999-12-31'::date)     as valid_to,
    s.dbt_valid_to is null                           as is_current

from {{ ref('user_snapshot_check') }} s
left join {{ ref('country_codes') }} c
    on s.country = c.country_code