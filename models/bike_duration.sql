SELECT
    cast(bike_id AS integer) AS bike_id,
    start_date,
    trip_count_last_week,
    trip_duration_last_week,
FROM
    {{ source(
        "dbt_meder_bike",
        "bike_duration"
    ) }}
