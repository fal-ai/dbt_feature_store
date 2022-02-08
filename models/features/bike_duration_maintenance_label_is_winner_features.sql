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
        start_date > timestamp('2020-01-01')
), maintenance AS (
    SELECT
        bike_id,
        timestamp,
        {{ next_timestamp("bike_id", "timestamp") }} AS next_timestamp,
    FROM
        {{ ref("bike_maintenance") }}
), label AS (
    SELECT
        bike_id,
        date,
        is_winner
    FROM {{ ref("bike_is_winner") }}
)
SELECT
    duration.trip_count_last_week,
    duration.trip_duration_last_week,

    maintenance.timestamp AS maintenance_timestamp,

    label.is_winner,
    label.bike_id,
    label.date AS label_date
FROM label
LEFT JOIN duration
    ON {{ label_feature_join(
            "label.bike_id",
            "label.date",
            "duration.bike_id",
            "duration.start_date",
            "duration.next_start_date"
        ) }}
LEFT JOIN maintenance
    ON {{ label_feature_join(
            "label.bike_id",
            "label.date",
            "maintenance.bike_id",
            "maintenance.timestamp",
            "maintenance.next_timestamp"
        ) }}
