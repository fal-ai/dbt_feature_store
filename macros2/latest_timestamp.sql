{% macro latest_timestamp(
        feature_table,
        entity_column,
        timestamp_column,
        feature_columns=['*']
    ) %}
SELECT
    {% for column in feature_columns %}
    {{ column }},
    {% endfor %}

    {{ entity_column }} AS __f__entity,
    {{ timestamp_column }} AS __f__timestamp,
    {{ next_timestamp(entity_column, timestamp_column) }} AS __f__next_timestamp
FROM {{ feature_table }}
WHERE __f__next_timestamp IS NULL
{% endmacro %}
