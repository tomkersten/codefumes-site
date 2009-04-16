Feature: User Sign-Up
  People are more likely to find value in content they have
  created and/or contributed to themselves, or that which
  is associated with an entity they respect (person, company, etc).
  In order to reliably identify people and content they have generated,
  the site must allow people to sign up for their own accounts.

    Background:
      Given no users exist

    Scenario: User signs up with invalid data
      When I go to the sign up page
      And I fill in "user_login" with "in"
      And I fill in "user_email" with "invalidemail"
      And I fill in "user_password" with "password"
      And I fill in "user_password" with ""
      And I press the button to create a user
      Then I should see an error message

    Scenario: User signs up with valid data
      When I go to the sign up page
      And I fill in "user_login" with "valid_login"
      And I fill in "user_email" with "email@person.com"
      And I fill in "user_password" with "password"
      And I fill in "user_password_confirmation" with "password"
      And I press the button to create a user
      Then I should see a notification
