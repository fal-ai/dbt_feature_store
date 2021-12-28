{% macro next_avaliable(
        feature_table_model,
        feature_columns,
        timestamp_column,
        entity_id_column
    ) %}
SELECT
    {% for column in feature_columns %}
        {{ column }},
    {% endfor %}

    {{ entity_id_column }} AS f_bike_id,
    LEAD(
        {{ timestamp_column }}
    ) over __f__timestamp_window AS __f__next_time,
    {{ timestamp_column }} AS __f__timestamp
FROM
    {{ ref(feature_table_model) }}
    window __f__timestamp_window AS (
        PARTITION BY {{ entity_id_column }}
        ORDER BY
            start_date ASC
    )
{% endmacro %}
