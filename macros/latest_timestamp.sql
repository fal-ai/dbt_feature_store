{% macro latest_timestamp(feature) %}

{% do __f__load_meta(feature) %}

WITH __f__latest_timestamp AS (
    SELECT
        *,
        {{ feature.entity_column }} AS __f__entity,
        {{ feature.timestamp_column }} AS __f__timestamp,
        {{ next_timestamp(feature.entity_column, feature.timestamp_column) }} AS __f__next_timestamp
    FROM {{ feature.table }}
)
SELECT
    {% for column in feature.columns %}
    {{ column }},
    {% endfor %}
    __f__entity,
    __f__timestamp
FROM __f__latest_timestamp
WHERE __f__next_timestamp IS NULL
{% endmacro %}
