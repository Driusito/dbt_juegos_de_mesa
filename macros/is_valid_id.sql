{% macro is_valid_id(column_name, pattern) %}
    {{ column_name }} is not null
    and upper(trim({{ column_name }})) not in ('NULL', 'N/A', 'NA', 'NONE', '')
    and regexp_like({{ column_name }}, '{{ pattern }}')
{% endmacro %}