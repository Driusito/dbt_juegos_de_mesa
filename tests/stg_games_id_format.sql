select game_id
from {{ ref('stg_games') }}
where not regexp_like(game_id, '^GAME-[0-9]{4}$')