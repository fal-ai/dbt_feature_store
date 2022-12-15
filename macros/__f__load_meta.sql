{% macro __f__load_meta(obj) %}
{% if not execute %}
    {{ return(obj) }}
{% endif %}

{% if feature_store.__f__is_relation(obj) %}
    {# Set default meta #}
    {% set meta = {} %}

    {# Find the meta of the `obj` relation #}
    {% set nodes = graph.nodes.values()
            | selectattr("database", "equalto", obj.table.database)
            | selectattr("schema", "equalto", obj.table.schema)
            | selectattr("alias", "equalto", obj.table.identifier)
            | list %}

    {% if nodes %}
        {% if nodes[0].resource_type == "model" %}
            {% set meta = nodes[0].config.meta %}
        {% elif nodes[0].resource_type == "source" %}
            {% set meta = nodes[0].meta %}
        {% endif %}
    {% endif %}

    {# Populate any non-set properties available in the feature_store meta #}
    {% for attr in ['entity_column', 'timestamp_column'] %}
        {% if not obj[attr] %}
            {% do obj.update({attr: meta.get('fal', {}).get('feature_store', {})[attr]}) %}
        {% endif %}
    {% endfor %}
{% endif %}

{% do feature_store.__f__assert_has_attr(obj, 'entity_column') %}
{% do feature_store.__f__assert_has_attr(obj, 'timestamp_column') %}
{% do feature_store.__f__assert_has_attr(obj, 'columns') %}
{% endmacro %}

{% macro __f__assert_has_attr(obj, name) %}
{% if not obj[name] %}
    {{ exceptions.raise_compiler_error("Table information for '" ~ obj.table ~ "' must include '" ~ name ~ "'") }}
{% endif %}
{% endmacro %}

{% macro __f__is_relation(obj) %}
{# NOTE: taken from https://github.com/dbt-labs/dbt-utils/blob/51ed999a44fcc7f9f502be11e5f190f5bc84ba4b/macros/cross_db_utils/_is_relation.sql #}
{% do return(obj.table is mapping and obj.table.get('metadata', {}).get('type', '').endswith('Relation')) %}
{% endmacro %}
