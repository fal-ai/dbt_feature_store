{% macro latest_timestamp(
        feature_table,
        entity_column,
        timestamp_column,
        feature_columns=['*']
    ) %}
WITH __f__latest_timestamp AS (
    SELECT
        *,
        {{ entity_column }} AS __f__entity,
        {{ timestamp_column }} AS __f__timestamp,
        {{ next_timestamp(entity_column, timestamp_column) }} AS __f__next_timestamp
    FROM {{ feature_table }}
)
SELECT
    {% for column in feature_columns %}
    {{ column }},
    {% endfor %}
    __f__entity,
    __f__timestamp
FROM __f__latest_timestamp
WHERE __f__next_timestamp IS NULL
{% endmacro %}
