select
    dbt_scd_id                                       as user_sk,
    user_id,
    username,
    email,
    country,
    user_type,
    dbt_valid_from                                   as valid_from,
    coalesce(dbt_valid_to, '9999-12-31'::date)       as valid_to,
    dbt_valid_to is null                             as is_current

from {{ ref('user_snapshot_check') }}