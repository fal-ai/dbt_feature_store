{{ latest_timestamp(
  ref('bike_duration'),
  'bike_id',
  'start_date',
  ['trip_duration_last_week', 'trip_count_last_week']
) }}
