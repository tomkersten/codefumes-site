Feature: User Sign-Up
  People are more likely to find value in content they have
  created and/or contributed to themselves, or that which
  is associated with an entity they respect (person, company, etc).
  In order to reliably identify people and content they have generated,
  the site must allow people to sign up for their own accounts.

    Background:
      Given no users exist

    Scenario: User signs up with invalid data
      When Sam goes to the sign up page
      And he fills in "user_login" with "in"
      And he fills in "user_email" with "invalidemail"
      And he fills in "user_password" with "password"
      And he fills in "user_password" with ""
      And he presses the button to create a user
      Then he should see an error message

    Scenario: User signs up with valid data
      Given this scenario is disabled due to a bug with Rails 2.3.8 and Webrat 0.7.0
      When Sam goes to the sign up page
      And he fills in "user_login" with "valid_login"
      And he fills in "user_email" with "email@person.com"
      And he fills in "user_password" with "password"
      And he fills in "user_password_confirmation" with "password"
      And he presses the button to create a user
      Then he should see a notification
