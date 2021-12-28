{% macro create_dataset(
        features,
        label_table_model,
        label_name
    ) %}
    {% set feature_columns = ["trip_count_last_week", "trip_duration_last_week"] %}
    {% set ns = namespace(
        label_table_timestamp_column = "",
        label_table_entity_id_column = ""
    ) %}
    {% if execute %}
        {% for node in graph.nodes.values() %}
            {% if node.unique_id == "model.my_new_project." + label_table_model %}
                {% do log(
                    node,
                    info = true
                ) %}
                {% set ns.label_table_timestamp_column = node.config.meta.fal.feature_store.timestamp %}
                {% set ns.label_table_entity_id_column = node.config.meta.fal.feature_store.entity_id %}
            {% endif %}
        {% endfor %}
    SELECT
        lb.{{ ns.label_table_entity_id_column }},
        lb.{{ ns.label_table_timestamp_column }},
        lb.{{ label_name }},
        {% for column in feature_columns %}
            {{ column }},
        {% endfor %}
    FROM
        {{ ref(label_table_model) }} AS lb

        {% for group in features %}
        {{ stage_table_join(
            "stg_" + group.feature_model_name + "_" + label_table_model,
            "date",
            "bike_id",
            label_name,
            ns.label_table_timestamp_column,
            ns.label_table_entity_id_column
        ) }}
    {% endfor %}
{% endif %}
{% endmacro %}

{% macro stage_table_join(
        stage_table_model_name,
        stage_table_timestamp_column,
        stage_table_entity_id_column,
        label_name,
        label_table_timestamp,
        label_table_entity_id
    ) %}
    INNER JOIN {{ ref(stage_table_model_name) }}
    ON lb.{{ label_table_entity_id }} = {{ stage_table_model_name }}.{{ stage_table_entity_id_column }}
    AND lb.{{ label_table_timestamp }} = {{ stage_table_model_name }}.{{ stage_table_timestamp_column }}
{% endmacro %}
