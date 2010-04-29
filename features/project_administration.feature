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
    And she submits the form
    And she should see "Twitter Tagger Modified"
