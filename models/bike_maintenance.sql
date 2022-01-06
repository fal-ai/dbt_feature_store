{{ config(
    materialized = 'table',
) }}

SELECT
    *
FROM 
    {{ source("samples", "bike_dataset_labels_maintenance_required") }}
