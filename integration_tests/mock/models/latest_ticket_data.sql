{{ feature_store.latest_timestamp(
    {
        'table': ref('ticket_sentiment_dataset'),
        'columns': ['description', 'submitter_id', 'is_positive']
    }
)}}
