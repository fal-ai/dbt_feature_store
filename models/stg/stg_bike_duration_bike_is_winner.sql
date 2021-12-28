-- depends_on: {{ ref('bike_duration') }}
-- depends_on: {{ ref('bike_is_winner') }}
{{ config(
    materialized = 'view',
) }}

SELECT
    *
FROM
    (
        {{ stage_feature_table(
            "bike_duration",
            ["trip_count_last_week", "trip_duration_last_week"],
            "bike_is_winner",
            "is_winner",
        ) }}
    )
