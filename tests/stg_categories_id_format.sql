select category_id
from {{ ref('stg_categories') }}
where not regexp_like(category_id, '^CAT-[0-9]{3}$')