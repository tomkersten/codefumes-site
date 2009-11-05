require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module IntegrationHelpers
  def login_as(persona)
    user_params = User.plan(persona.to_sym)
    password = user_params[:password]
    user = User.find_by_login(user_params[:login]) || User.make(persona)
    visit login_path
    fill_in "user_session_login", :with => user.login
    fill_in "user_session_password", :with => password
    click_button
  end
end

describe "Project Administration" do
  include IntegrationHelpers
  before(:each) do
    activate_authlogic
    @user = User.make(:dora)
    @project = Project.make(:twitter_tagger, :owner => @user)
    login_as(:dora)
  end

  it "converting a public project to private" do
    visit short_uri_path(@project)
    response.should_not have_tag(".private")
    click_button "update_visibility"
    response.should have_tag(".visibility.private")
  end
end
