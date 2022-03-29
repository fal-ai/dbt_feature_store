{{ config(materialized='table') }}

with source_data as (

    select * from {{ ref('raw_zendesk_sentiment') }}
)

select
    id,
    score,
    date as calc_date,
    (case when label='POSITIVE' then 1 else 0 end) is_positive
from source_data
