# dbt_feature_store

<!--This table of contents is automatically generated. Any manual changes between the ts and te tags will be overridden!-->
<!--ts-->
<!--te-->

# About

This packages contains macros to help you build your feature store right in dbt.

# Usage

## Inside of dbt Models

> **NOTE:** to see a full example of the package in use, go to [dbt_feature_store_example](https://github.com/fal-ai/dbt_feature_store_example)

You can models with these macros to maintain a feature store updated with your dbt runs.

## From fal client (coming soon)

Trigger feature store calculations from a the fal client to iterate and test possible
features of interest before comitting with any specific one.


# Macros

## Plug-n-play Macros

### create_dataset ([source](/macros/create_dataset.sql))

Constructor: `feature_store.create_dataset(label, features)`

- `label`: [feature_table object](#feature_table-object)
- `features`: list of [feature_table objects](#feature_table-object)

Example:

```jinja
SELECT * 
FROM (

  {{ create_dataset(
      { 
        'table': source('dbt_bike', 'bike_is_winner'), 
        'columns': ['is_winner'] 
      },
      [
        { 
          'table': ref('bike_duration'), 
          'columns': ['trip_duration_last_week', 'trip_count_last_week'] 
        }
      ]
  ) }}

)
```

### latest_timestamp ([source](/macros/latest_timestamp.sql))

Constructor: `feature_store.latest_timestamp(feature)`

- `feature`: [feature_table object](#feature_table-object)


## Building blocks Macros

### next_timestamp ([source](/macros/next_timestamp.sql))

Constructor: `feature_store.next_timestamp(entity_column, timestamp_column)`

- `entity_column`: column name of id of rows for joining a label tables and feature tables
- `timestmap_column`: column name of timestamp/date of rows for joining a label tables and feature tables

### label_feature_join ([source](/macros/label_feature_join.sql))

Constructor: `feature_store.label_feature_join(label_entity_column, label_timestamp_column, feature_entity_column, feature_timestamp_column, feature_next_timestamp_column)`

- `label_entity_column`: column name of id of rows for joining a label tables and feature tables
- `label_timestamp_column`: column name of timestamp/date of rows for joining a label tables and feature tables
- `feature_entity_column`: column name of id of rows for joining a label tables and feature tables
- `feature_timestamp_column`: column name of timestamp/date of rows for joining a label tables and feature tables
- `feature_next_timestamp_column`: column pre-calculated (normally in a CTE) with the call of the macro [feature_store.next_timestamp(feature_entity_column, feature_timestamp_column)](#next_timestamp)


# feature_table object

A feature_table object is a Python dict with the following properties:

- `table`: a `ref`, `source` or name of a CTE defined in the query
- `columns`: a list of columns from the label relation to appear in the final query
- `entity_column` (optional): column name of id of rows for joining a label tables and feature tables
- `timestmap_column` (optional): column name of timestamp/date of rows for joining a label tables and feature tables

If you pass a [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref/) or [source](https://docs.getdbt.com/reference/dbt-jinja-functions/source/) in the `table` property, you can skip the `entity_column` and `timestamp_column` properties, as they will be loaded from the [schema.yml](https://docs.getdbt.com/reference/resource-properties/schema) `meta` for models or sources.

```yml
version: 2
sources:
  - name: dbt_bike
    tables:
      - name: bike_is_winner
        meta:
          # source example
          fal:
            feature_store:
              entity_column: bike_id
              timestamp_column: date

models:
  - name: bike_duration
    meta:
      # model example
      fal:
        feature_store:
          entity_column: bike_id
          timestamp_column: start_date
```

