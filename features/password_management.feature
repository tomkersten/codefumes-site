Feature: Password Management
  For security purposes and to meet the expectations
  of anyone who has used a website in the last decade,
  we have to implement at least simple account managment
  functionality. One such feature would be password
  managment.

  Scenario: Resetting your password when logged in
    Given this scenario is disabled due to a bug with Rails 2.3.8 and Webrat 0.7.0
    Given Dora signs in
    When she follows "Edit Account"
    And she fills in "user_password" with "password"
    And she fills in "user_password_confirmation" with "password"
    And she submits the form
    Then she should see a notification message
