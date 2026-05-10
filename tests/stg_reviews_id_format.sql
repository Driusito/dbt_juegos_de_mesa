select review_id
from {{ ref('stg_reviews_incremental') }}
where not regexp_like(review_id, '^REV-[0-9]{5}$')