{{ feature_store.create_dataset(
    {
        'table': ref('zendesk_sentiment'),
        'columns': ['is_positive']
    },
    [{
        'table': ref('zendesk_ticket_data'),
        'columns': ['description', 'submitter_id']
    }]
) }}
