require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe My::ProjectsController do
  before(:each) {activate_authlogic}

  context "when an authenticated user makes" do
    before(:each) do
      @user = login_as :dora
    end

    describe "GET to index" do
      before(:each) do
        Project.make
        @claimed_projects = 2.times.map {Project.make(:user => @user)}
      end

      it "assigns the logged in user's projects for the view template" do
        get :index
        assigns[:projects].should == @claimed_projects
      end
    end
  end

  context "an anonymous request" do
    describe "to visit /my/projects (GET request)" do
      it "is redirected to the login page" do
        controller.stub!(:current_user).and_return(nil)
        get :index
        response.should redirect_to(login_path)
      end
    end
  end
end
