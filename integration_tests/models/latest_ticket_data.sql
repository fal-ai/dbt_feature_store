{{ feature_store.latest_timestamp(
    {
        'table': ref('zendesk_ticket_data'),
        'columns': ['description', 'submitter_id']
    }
)}}
