def create_user(params = {})
  pwd = "password"
  user_params = {:login => "jdoe", :password => pwd, :password_confirmation => pwd, :email => "jdoe@example.com"}.merge(params)
  User.create(user_params)
end

Given /no users exist/ do
  User.destroy_all
end

When /^s?he presses the button to create a(?:n)? (\w+)$/ do |model_type|
  button_dom_id = "create_#{model_type.downcase}"
  click_button(button_dom_id)
end

#When /^I go to the login page$/ do
#  visit login_path
#end

When /^(?:Oscar|Sam|Dora|Someone) attempts to sign in with incorrect credentials$/ do
  When "I go to the login page"
  fill_in("user_session_login", :with => "wrong_username")
  fill_in("user_session_password", :with => "some_wrong_password")
  click_button("attempt_login")
end

When /^(?:Oscar|Sam|Dora|Someone|he|she) signs in with incorrect credentials$/ do
  When "Someone attempts to sign in with incorrect credentials"
end

Then /^s?he logs out$/ do
  click_link("Log out")
end

Then /^s?he should see the login form$/ do
  response.should have_tag("form#login_form")
end

Given /^s?he am signed up as "(.*)\/(.*)"$/ do |login, password|
  user = create_user(:login => login, :password => password, :password_confirmation => password)
end

Then /^s?he should not see link to logout$/ do
  response.should_not have_tag("a.logout")
end

Then /^s?he should see the link to logout$/ do
  response.should have_tag("a.logout")
end

Then /^he should see the link to his list of projects$/ do
  response.should have_tag("a.project_list")
end

Then /^he should see the link to edit his account$/ do
  response.should have_tag("a.edit_account")
end

Given /^(Oscar|Sam|Dora) has set up his|her account$/ do |persona|
  @user = User.make(persona.downcase.to_sym)
end

When /^(Oscar|Dora|Sam) signs in$/ do |persona|
  persona_params = User.plan(persona.downcase.to_sym)
  @user = User.find_or_create_by_email(persona_params)
  add_subscriptions_for(@user)
  When "I go to the login page"
  fill_in("user_session_login", :with => @user.login)
  fill_in("user_session_password", :with => persona_params[:password])
  click_button("attempt_login")
end


def add_subscriptions_for(user)
  if user.login.match(/dora/i)
    Subscription.make(:doras, :user => @user)
    user.reload
  end
end
