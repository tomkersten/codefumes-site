require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe My::ProjectsController do
  before(:each) {activate_authlogic}

  context "when an authenticated user makes" do
    before(:each) do
      @user = login_as :dora
    end

    describe "a GET to index" do
      before(:each) do
        Project.make
        @claimed_projects = 2.times.map {Project.make(:owner => @user)}
      end

      it "assigns the logged in user's projects for the view template" do
        get :index
        assigns[:projects].should == @claimed_projects
      end
    end

    describe "a GET to edit" do
      before(:each) do
        @project = Project.make(:owner => @user)
      end

      it "assigns the specified project for the view template" do
        get :edit, :id => @project.to_param
        assigns[:project].should == @project
      end
    end

    describe "a PUT to update" do
      before(:each) do
        @project = Project.make(:twitter_tagger, :owner => @user)
        @new_name = @project.name + " Modified"
        @params = {:name => @new_name}
      end

      def perform_request
        put :update, :id => @project.to_param, :project => @params
      end

      it "updates the project" do
        perform_request
        @project.reload
        @project.name.should == @new_name
      end

      it "redirects back to the project's short_uri page" do
        perform_request
        response.should redirect_to(short_uri_path(@project))
      end

      context "with the public key of a project the user does not own" do
        before(:each) do
          @project = Project.make(:owner => User.make(:oscar))
          @original_project_name = @project.name
        end

        it "does not update the project" do
          perform_request
          @project.reload
          @project.name.should == @original_project_name
        end

        it "redirects to the user's list of projects" do
          perform_request
          response.should redirect_to(my_projects_path)
        end

        it "notifies the user that the action was not allowed" do
          perform_request
          flash[:error].should_not be_nil
        end
      end
    end

    describe "a PUT to set_visibility" do
      before(:each) do
        @project = Project.make(:public, :owner => @user)
      end

      def perform_request
        put :set_visibility, :id => @project.to_param, :project => {:visibility => "private"}
      end

      it "updates the visibility to the value provided" do
        @project.should_not be_private
        perform_request
        @project.reload
        @project.should be_private
      end

      it "redirects to the short_uri path" do
        perform_request
        response.should redirect_to(short_uri_path(@project))
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
