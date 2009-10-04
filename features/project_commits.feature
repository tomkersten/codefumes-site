Feature: Viewing Commits
  The value of this site is its ability to collate data around
  a software project at different points in time. Commits will
  be the "points" used for reference, and are therefore, an
  imperative component of a project 

  Scenario: Viewing "twitter_tagger" commits
    Given the "twitter_tagger" project has been created
    And the project has 5 commits
    When Sam goes to the project's short_uri page
    Then he sees a list of commits with 5 items in it

  Scenario: Dora views "prideo"
    Given the "prideo" project has been created
    And the project has 5 commits
    When Dora goes to the project's short_uri page
    Then she sees a list of commits with 5 items in it
    And she sees the private key of the project

  Scenario: Sam views "prideo"
    Given the "prideo" project has been created
    And the project has 5 commits
    When Sam goes to the project's short_uri page
    Then he sees a list of commits with 5 items in it
    And he does not see the private key of the project
