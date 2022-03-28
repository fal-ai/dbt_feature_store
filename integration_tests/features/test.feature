Feature: create_dataset
  Scenario: create_dataset works
    Given `dbt run --profiles-dir .` is run
    When `fal run --profiles-dir . --select ticket_sentiment_dataset` is run
    Then outputs for ticket_sentiment_dataset contain results
