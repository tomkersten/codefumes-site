Feature: Viewing Commits
  The value of this site is its ability to collate data around
  a software project at different points in time. Commits will
  be the "points" used for reference, and are therefore, an
  imperative component of a project

  Scenario: Hiding new project reminder message
    Given a public project has been created
    When Dora goes to the project's short_uri page
    And she acknowledges the new project reminder message
    Then she does not see a new project reminder message

  Scenario: Attempting to view a private project you don't own
    Given the "prideo" project has been created
    And the project has 5 commits
    When Sam goes to the project's short_uri page
    Then he should see a private project message
