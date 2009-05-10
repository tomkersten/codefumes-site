Feature: Project creation
  Projects are the central collection point for statistics
  on the site. Users (both authenticated and unauthenticated)
  must be able to create a project and associate metrics to it.

  Background:
    Given no projects exist

  Scenario: Viewing a short-url page for a project that does not exist
    Given Sam goes to the home page
    When he follows "short_uri"
    Then he should see instructions for how to reserve that URI
