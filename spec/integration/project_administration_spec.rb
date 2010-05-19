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
    response.should_not have_tag(".private-project")
    response.should have_tag(".public-project")
    click_link("Edit Project")
    within("#update_visibility") do |update_form|
      update_form.click_button
    end
    response.should have_tag(".private-project")
    response.should_not have_tag(".public-project")
  end

  it "deleting a project" do
    extra_project = Project.make(:owner => @user)
    visit edit_my_project_path(@project)
    within("#delete_project_#{@project.id}") do |delete_form|
      delete_form.click_button
    end

    within(".projects") do |project_list|
      project_list.should_not have_text(@project)
    end

    within(".notice") do |notice_box|
      notice_box.should have_tag(".notice")
    end
  end
end
