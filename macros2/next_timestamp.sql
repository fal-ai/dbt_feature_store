{% macro next_timestamp(entity_column, timestamp_column) %}
lead({{ timestamp_column }}) OVER (
    PARTITION BY {{ entity_column }}
    ORDER BY {{ timestamp_column }} ASC
)
{% endmacro %}
