{{ config(materialized='table') }}

with source_data as (

    select * from {{ ref('raw_zendesk_ticket_data') }}
)

select id,created_at,description,subject,submitter_id,url
from source_data
