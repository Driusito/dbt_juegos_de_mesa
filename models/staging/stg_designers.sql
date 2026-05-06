with 

source as (

    select * from {{ source('bronze', 'designers') }}

),
nationalities as (
    select 
        designer_id,
        name,
        CASE trim(upper(nationality))
            WHEN 'PT' THEN 'Portugal'
            WHEN 'US' THEN 'Estados Unidos'
            WHEN 'PL' THEN 'Polonia'
            WHEN 'SK' THEN 'Eslovaquia'
            WHEN 'HU' THEN 'Hungría'
            WHEN 'DE' THEN 'Alemania'
            WHEN 'FR' THEN 'Francia'
            WHEN 'CA' THEN 'Canadá'
            WHEN 'CZ' THEN 'Chequia'
            WHEN 'RU' THEN 'Rusia'
            WHEN 'NZ' THEN 'Nueva Zelanda'
            WHEN 'IT' THEN 'Italia'
            WHEN 'GB' THEN 'Reino Unido'
            WHEN 'ES' THEN 'España'
            WHEN 'AT' THEN 'Austria'
            WHEN 'AU' THEN 'Australia'
            ELSE nationality
        END AS country_name,
        birth_year,
        _loaded_at
    from source
),

renamed as (

    select
        designer_id,
        initcap(name),
        country_name,
        coalesce(to_varchar(birth_year),'Sin fecha de nacimiento - Por defecto: 01/01/2000') as birth_year_clean,
        _loaded_at

    from nationalities

)

select * from renamed