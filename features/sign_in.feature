Feature: Signing into a session
  Users will not create content they value if they are not able to
  securely access it in the future. In order to make this possible,
  we must give them the ability to sign into the site. The current
  preferred method of doing so is the standard login/password seen
  on most websites.

    Background:
      Given no users exist

    Scenario: User is not signed up
      Given Oscar signs in with incorrect credentials
      Then he should see an error message
      And he should see the login form
      And he should not see link to logout

    Scenario: User signs in successfully
      Given Oscar has set up his account
      And he has claimed the following projects:
        |name     |
        |Tweeter  |
        |YourSpace|
      When Oscar signs in
      Then he should see the link to logout
      And he should see a list of his claimed projects

    Scenario: User enters wrong password
      Given Oscar has set up his account
      And he signs in with incorrect credentials
      Then he should see an error message
      And he should see the login form
      And he should not see link to logout

