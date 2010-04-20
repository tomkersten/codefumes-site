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

describe "Project Builds" do
  include IntegrationHelpers
  before(:each) do
    activate_authlogic
    @user = User.make(:dora)
    @project = Project.make(:twitter_tagger, :owner => @user)
    @commit = @project.commits.create(Commit.plan)
    login_as(:dora)
  end

  it "marking projects with a failed build associated with the most recent commit" do
    @commit.builds.create!(Build.plan(:failed))
    visit my_projects_path
    response.should have_tag(".#{Commit::FAILED_BUILD}")
  end

  it "doesn't mark projects in a 'clean' state as '#{Commit::FAILED_BUILD}'" do
    @commit.builds.create!(Build.plan(:success))
    visit my_projects_path
    response.should_not have_tag(".#{Commit::FAILED_BUILD}")
  end

  it "marks projects in a 'clean' state as '#{Commit::SUCCESSFUL_BUILD}'" do
    @commit.builds.create!(Build.plan(:successful))
    visit my_projects_path
    response.should have_tag(".#{Commit::SUCCESSFUL_BUILD}")
  end

  it "doesn't throw an error if a project does not have a build status" do
    visit my_projects_path
    response.should be_success
    response.should have_text(/#{@project.name}/)
  end
end
