Feature: Upgrade reminders
Instead of preventing users from creating a larger number
of private projects than their current plan allows, we will
encourage it.  The site will allow users to create private
projects and give them 1 full week of usage before turning
off the "view"/"read" functionality (ie: users will still
be able to "add" content to a project).

  Background:
    Given the database has been set up with the standard plans
    And Dora signs in
    And she has claimed the following projects:
    |public_key  |visibility  |privatized_at  |
    |project1    |private     |9.days.ago     |
    |project2    |private     |8.days.ago     |
    |project3    |private     |6.days.ago     |


  Scenario: Being prompted to upgrade on "extra" private projects
    When she visits the "project2" project page
    Then she should see that the visualizations are disabled
