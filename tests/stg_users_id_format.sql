select user_id
from {{ ref('stg_users') }}
where not regexp_like(user_id, '^usr-[0-9]{4}$')
