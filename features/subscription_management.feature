Feature: Subscription Management
  In the event that a user would like to have "private" projects, they
  will be required to have a subscription to the site.  Additionally,
  as users increase and decrease their usage of "private" projects, they
  must be able to update their subscription level accordingly.

  Background:
    Given the database has been set up with the standard plans

  # Oscar decides to set up a subscription for an internal project
  Scenario: Setting up a new subscription with an existing account
    When Oscar goes to his list of projects
    Then he should see the "new_subscription" link
    When he follows "new_subscription"
    And he fills out and submits in the subscription form, selecting the Basic plan
    Then he should see a confirmation form
    When he confirms the information
    Then he should see a notification message
    And he should not see the "new_subscription" link


  Scenario: Reviewing your account status
    When Dora goes to her account information page
    Then she should see her current plan
