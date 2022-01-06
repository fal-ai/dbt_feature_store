{{ config(
    materialized = 'table',
) }}

WITH duration AS (
    SELECT
        bike_id,
        start_date,
        {{ next_timestamp("bike_id", "start_date") }} AS next_start_date,

        -- features
        trip_count_last_week,
        trip_duration_last_week
    FROM
        {{ ref("bike_duration") }}
    WHERE
        -- NOTE: Offer users an opportunity to sanitize
        bike_id IS NOT NULL
), maintenance AS (
    SELECT
        bike_id,
        timestamp,
        {{ next_timestamp("bike_id", "timestamp") }} AS next_timestamp,
    FROM
        {{ ref("bike_maintenance") }}
), lb AS (
    SELECT
        bike_id,
        cast(date AS timestamp) AS date,
        is_winner
    FROM
        {{ ref("bike_is_winner") }}
)
SELECT
    lb.bike_id,

    lb.date AS label_date,
    lb.is_winner,

    duration.start_date AS trip_start_date,
    duration.trip_count_last_week,
    duration.trip_duration_last_week,

    maintenance.timestamp AS maintenance_timestamp
FROM lb
LEFT JOIN duration
    ON {{ label_feature_join(
            "lb.bike_id",
            "lb.date",
            "duration.bike_id",
            "duration.start_date",
            "duration.next_start_date"
        ) }}
LEFT JOIN maintenance
    ON {{ label_feature_join(
            "lb.bike_id",
            "lb.date",
            "maintenance.bike_id",
            "maintenance.timestamp",
            "maintenance.next_timestamp"
        ) }}
