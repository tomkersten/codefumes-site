Feature: Viewing Commits
  The value of this site is its ability to collate
  data around a software project at different points
  in its history. Commits will be the "points" used
  for reference, and are therefore, imperative that
  users of the site can view a history of project
  commits.

  Background:
    Given the "twitter_tagger" project has been created
    And the project has 5 commits

  Scenario: Viewing "twitter_tagger" commits
    When Sam goes to the project's short_uri page
    Then he should see its list of commits with 5 items in it
