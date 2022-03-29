Feature: latest_timestamp
  Scenario: latest_timestamp works
    Given `dbt run --profiles-dir .` is run
    When `fal run --profiles-dir . --select latest_ticket_data` is run
    Then outputs for latest_ticket_data contain results
