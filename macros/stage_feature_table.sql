{% macro stage_feature_table(
        feature_table_model,
        feature_columns,
        label_table_model,
        label_column
    ) %}
    {% set ns = namespace(
        timestamp_column = "",
        entity_id_column = "",
        label_timestamp_column = "",
        label_entity_id_column = ""
    ) %}
    {% if execute %}
        {% set node = graph.nodes["model.my_new_project." + feature_table_model] %}
        {% set ns.timestamp_column = node.config.meta.fal.feature_store.timestamp %}
        {% set ns.entity_id_column = node.config.meta.fal.feature_store.entity_id %}

        {% set node = graph.nodes["model.my_new_project." + label_table_model] %}
        {% set ns.label_timestamp_column = node.config.meta.fal.feature_store.timestamp %}
        {% set ns.label_entity_id_column = node.config.meta.fal.feature_store.entity_id %}

        WITH __f__most_recent AS (
            {{ next_avaliable(
                feature_table_model,
                feature_columns,
                ns.timestamp_column,
                ns.entity_id_column
            ) }}
        )
    SELECT
        {{ ns.label_entity_id_column }},
        {{ ns.label_timestamp_column }},
        {% for column in feature_columns %}
            {{ column }},
        {% endfor %}

        {{ label_column }}
    FROM
        {{ ref(label_table_model) }} AS lb
        LEFT JOIN __f__most_recent AS mr
        ON CAST(
            lb.{{ ns.label_entity_id_column }} AS STRING
        ) = mr.f_bike_id
        AND mr.__f__timestamp < CAST(
            lb.{{ ns.label_timestamp_column }} AS TIMESTAMP
        )
        AND (
            mr.__f__next_time IS NULL
            OR CAST(
                lb.{{ ns.label_timestamp_column }} AS TIMESTAMP
            ) <= mr.__f__next_time
        )
    {% endif %}
{% endmacro %}
