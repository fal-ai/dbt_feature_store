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
        start_date > date('2020-01-01')
), maintenance AS (
    SELECT
        bike_id,
        cast(timestamp AS date) AS date,
        {{ next_timestamp("bike_id", "cast(timestamp AS date)") }} AS next_date,
    FROM
        {{ ref("bike_maintenance") }}
), label AS (
    SELECT
        bike_id,
        date,
        is_winner
    FROM {{ source("dbt_meder_bike", "bike_is_winner") }}
)
SELECT
    duration.trip_count_last_week,
    duration.trip_duration_last_week,

    maintenance.date AS maintenance_date,

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
            "maintenance.date",
            "maintenance.next_date"
        ) }}
