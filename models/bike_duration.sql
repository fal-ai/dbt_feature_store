SELECT
    *
FROM
    {{ source(
        "dbt_meder_bike",
        "bike_duration"
    ) }}
