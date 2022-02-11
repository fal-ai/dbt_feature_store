{% macro create_dataset(
        label,
        features
    ) %}

{% if not execute %}
    {{ return('') }}
{% endif %}

{# Load and assert we have necessary attributes #}
{% do __f__load_meta(label) %}
{% for feature in features %}
    {% do __f__load_meta(feature) %}
{% endfor %}

WITH __f__label AS (
    SELECT
        {% for column in label.columns %}
        {{ column }},
        {% endfor %}

        {{ label.entity_column }} AS __f__entity_column,
        {{ label.timestamp_column }} AS __f__timestamp_column
    FROM {{ label.table }}
)

{# Set internal CTE names for future usage #}
{% for feature in features %}
    {% set lookalike = dbt_utils.slugify(feature.table) | reverse | truncate(30, False, '', 0) | reverse %}
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

    {% for column in label.columns %}
        __f__label.{{ column }},
    {% endfor %}

    {% if label.entity_column not in label.columns %}
        __f__label.__f__entity_column AS {{ label.entity_column }},
    {% endif %}
    {% if label.timestamp_column not in label.columns %}
        __f__label.__f__timestamp_column AS {{ label.timestamp_column }},
    {% endif %}
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
