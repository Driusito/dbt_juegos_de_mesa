select collection_id, user_id, game_id
from {{ ref('stg_collections') }}
where not regexp_like(collection_id, '^COL-[0-9]{5}$')
   or not regexp_like(user_id,       '^USR-[0-9]{4}$')
   or not regexp_like(game_id,       '^GAME-[0-9]{4}$')