-- CTE for later usage, make sure to pass the CTE name, not a ref call (see cte_bike_maintenance feature)
WITH cte_bike_maintenance AS (
    SELECT 
        -- renaming of columns as necessary
        bike_id AS maintenance_id, 
        cast(timestamp AS date) AS maintenance_date
    FROM {{ ref('bike_maintenance') }}
)
SELECT * 
FROM (
{{ create_dataframe(
    {
        'table': source('dbt_meder_bike', 'bike_is_winner'),
        'columns': ['is_winner']
    },
    [{
        'table': ref('bike_duration'),
        'entity_column': 'bike_id',
        'timestamp_column': 'start_date',
        'columns': ['trip_duration_last_week']
    }, {
        'table': ref('bike_duration'),
        'columns': ['trip_count_last_week']
    }, {
        'table': 'cte_bike_maintenance',
        'entity_column': 'maintenance_id',
        'timestamp_column': 'maintenance_date',
        'columns': ['maintenance_date']
    }]
) }}
)
