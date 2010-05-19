Feature: Project Administration
  Projects are the central collection point for statistics
  on the site. Users (both authenticated and unauthenticated)
  must be able to create a project and associate metrics to it.

  Background:
    Given no projects exist

  Scenario: Editing the name of a project
    Given the "twitter_tagger" project has been created
    When Dora goes to the project's short_uri page
    And she follows the link to edit the project
    And she fills in "project_name" with "Twitter Tagger Modified"
    And she presses "Save changes"
    Then she should see "Twitter Tagger Modified"
    And she should see a notification message

  Scenario: Viewing a project's public & private key
    Given the "twitter_tagger" project has been created
    When Dora goes to the project's short_uri page
    And she follows the link to edit the project
    Then she sees the private key of the project
