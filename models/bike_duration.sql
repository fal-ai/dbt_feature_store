SELECT
    cast(bike_id AS integer) AS bike_id,
    cast(start_date AS date) AS start_date,
    trip_count_last_week,
    trip_duration_last_week,
FROM
    {{ source(
        "dbt_meder_bike",
        "bike_duration"
    ) }}
