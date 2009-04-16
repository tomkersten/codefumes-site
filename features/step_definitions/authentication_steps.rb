def create_user(params = {})
  pwd = "password"
  user_params = {:login => "jdoe", :password => pwd, :password_confirmation => pwd, :email => "jdoe@example.com"}.merge(params)
  User.create(user_params)
end

Given /no users exist/ do
  User.destroy_all
end

When /^I press the button to create a(?:n)? (\w+)$/ do |model_type|
  button_dom_id = "create_#{model_type.downcase}"
  click_button(button_dom_id)
end

When /^I sign in as "(.*)\/(.*)"$/ do |login, password|
  When "I go to the login page"
  fill_in("user_session_login", :with => login)
  fill_in("user_session_password", :with => password)
  click_button("attempt_login")
end

Then /^I log out$/ do
  click_link("logout")
end

Then /^I should see the login form$/ do
  response.should have_tag("form#login_form")
end

Given /^I am signed up as "(.*)\/(.*)"$/ do |login, password|
  user = create_user(:login => login, :password => password, :password_confirmation => password)
end

Then /^I should not see link to logout$/ do
  response.should_not have_tag("a#logout")
end

Then /^I should see link to logout$/ do
  response.should have_tag("a#logout")
end
