{% macro label_feature_join(
        label_entity_column, 
        label_timestamp_column, 
        feature_entity_column, 
        feature_timestamp_column, 
        feature_next_timestamp_column
    ) %}
{{ label_entity_column }} = {{ feature_entity_column }} 
    AND {{ feature_timestamp_column }} < {{ label_timestamp_column }} 
    AND ({{ feature_next_timestamp_column }} IS NULL 
        OR {{ label_timestamp_column }} <= {{ feature_next_timestamp_column }})
{% endmacro %}
