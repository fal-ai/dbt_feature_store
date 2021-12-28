-- depends_on: {{ ref('bike_duration') }}
-- depends_on: {{ ref('bike_is_winner') }}
-- depends_on: {{ ref('stg_bike_duration_bike_is_winner') }}
{{ config(
    materialized = 'table',
) }}

SELECT
    *
FROM
    (
        {{ create_dataset(
            [{ "feature_model_name": "bike_duration", "column_names": ["trip_count_last_week", "trip_duration_last_week"],
            "stage_table_model": "stg_bike_duration_is_winner" }],
            "bike_is_winner",
            "is_winner",
        ) }}
    )
