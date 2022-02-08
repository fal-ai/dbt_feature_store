{% macro create_dataframe(
        label,
        features
    ) %}

WITH __f__label AS (
    SELECT
        {{ label.column }},
        {{ label.entity_column }} AS __f__entity_column,
        {{ label.timestamp_column }} AS __f__timestamp_column
    FROM {{ label.table }}
)

{# Set CTE names for future usage #}
{% for feature in features %}
    {% set lookalike = dbt_utils.slugify(feature.table) | string | reverse | truncate(30, False, '', 0) | reverse %}
    {# HACK: making sure CTE names are different based on current timestamp's seconds and microseconds #}
    {% set millis = dbt_utils.pretty_time(format='%S%f') %}
    {% do feature.update({'__f__cte_name': '__f__cte_' + lookalike + '_' + millis}) %}
{% endfor %}

{% for feature in features %}
    , {{ feature.__f__cte_name }} AS (
        SELECT
            {% for column in feature.columns %}
            {{ column }},
            {% endfor %}

            {{ feature.entity_column }} AS __f__entity_column,
            {{ feature.timestamp_column }} AS __f__timestamp_column,
            {{ next_timestamp(
                feature.entity_column,
                feature.timestamp_column
            ) }} AS __f__next_timestamp
        FROM {{ feature.table }}
    )
{% endfor %}
SELECT
    {% for feature in features %}
        {% for column in feature.columns %}
        {{ feature.__f__cte_name }}.{{ column }},
        {% endfor %}
    {% endfor %}

    {% if label.entity_column != label.column %}
        __f__label.__f__entity_column AS {{ label.entity_column }},
    {% endif %}
    {% if label.timestamp_column != label.column %}
        __f__label.__f__timestamp_column AS {{ label.timestamp_column }},
    {% endif %}
    __f__label.{{ label.column }}
FROM __f__label

{% for feature in features %}
LEFT JOIN {{ feature.__f__cte_name }}
    ON {{ label_feature_join(
            '__f__label.__f__entity_column',
            '__f__label.__f__timestamp_column',
            feature.__f__cte_name + '.__f__entity_column',
            feature.__f__cte_name + '.__f__timestamp_column',
            feature.__f__cte_name + '.__f__next_timestamp'
        ) }}
{% endfor %}

{% endmacro %}
