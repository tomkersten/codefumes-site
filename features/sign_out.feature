Feature: Signing out of a session
  Users will not create content they value if they are not able to
  ensure it will be safe from malicious users. In order to make
  such an assurance to our users, we must give them the ability to
  sign out of their session

  Background:
    Given I am signed up as "jdoe/password"
    And I sign in as "jdoe/password"

  Scenario: User signs out
    When I log out
    And I should see the login form
