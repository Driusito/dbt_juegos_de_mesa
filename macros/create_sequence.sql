{% macro create_sequence() %}
    create sequence if not exists SEQUENCE_CATEGORY;
{% endmacro %}
