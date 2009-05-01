Feature: Signing into a session
  Users will not create content they value if they are not able to
  securely access it in the future. In order to make
  this possible, we must give them the ability to
  sign into the site. The current preferred method of doing so is
  the standard login/password seen on most websites.

    Background:
      Given no users exist

    Scenario: User is not signed up
      And I sign in as "jdoe/password"
      Then I should see an error message
      And I should see the login form
      And I should not see link to logout

#    Scenario: User enters wrong password
#      Given I am signed up as "jdoe/password"
#      And I sign in as "jdoe/wrongpassword"
#      Then I should see an error message
#      And I should see the login form
#      And I should not see link to logout
#
#    Scenario: User signs in successfully
#      Given I am signed up as "jdoe/password"
#      And I sign in as "jdoe/password"
#      Then I should see link to logout
