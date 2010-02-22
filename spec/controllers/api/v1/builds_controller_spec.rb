require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::BuildsController do
  before(:each) do
    @project = Project.make
    @commit = @project.commits.create!(Commit.plan)
    @request.env["HTTP_ACCEPT"] = "application/xml"
  end

  describe "a GET to index" do
    before(:each) do
      @builds = (1..3).map {Build.make(:commit_id => @commit.id)}
    end

    def perform_request
      get :index, :project_id => @project.to_param, :commit_id => @commit.to_param
    end

    it "assigns all builds associated with the specified commit for the view template" do
      perform_request
      assigns[:builds].should == @builds
    end
  end

  describe "a GET to show" do
    def perform_request
      get :show, :project_id => @project.to_param, :commit_id => @commit.to_param, :id => @build.to_param
    end

    context "when the requested resource exists" do
      before(:each) do
        @build = @commit.builds.create!(Build.plan)
      end

      it "assigns the specified project for the view template" do
        perform_request
        assigns[:build].should == @build
      end

      it "returns a response code of 200 OK" do
        perform_request
        response.status.should == "200 OK"
      end

      it "sets the 'Location' header to the build URI" do
        perform_request
        response.headers["Location"].should == api_v1_project_commit_build_url(:xml, @project, @commit, @build)
      end
    end

    context "when the requested resource does not exist" do
      before(:each) do
        Build.destroy_all
        @build = @commit.builds.new(Build.plan)
      end

      it "returns a response code of 404 Not Found" do
        perform_request
        response.status.should == "404 Not Found"
      end
    end
  end

  describe "a POST to create" do
    before(:each) do
      @build_params = Build.plan
    end

    def perform_request
      post :create, :project_id => @project.to_param, :commit_id => @commit.to_param, :build => @build_params
    end

    context "without passing in valid authentication credentials" do
      it "returns a '401 Unauthorized' response" do
        perform_request
        response.status.should == "401 Unauthorized"
      end
    end

    context "when successfully authenticated" do
      before(:each) do
        setup_basic_auth(@project.public_key, @project.private_key)
      end

      context "when a valid request is made" do
        it "assigns the newly created build object for the view template" do
          perform_request
          assigns[:build].should_not be_nil
          assigns[:build].should be_valid
        end

        it "returns a response code of 201 Created" do
          perform_request
          response.status.should == "201 Created"
        end

        it "sets the 'Location' header to the build URI" do
          perform_request
          response.headers["Location"].should == api_v1_project_commit_build_url(:xml, @project, @commit, assigns[:build])
        end
      end

      context "when an invalid request is made" do
        it "returns a response code of '422 Unprocessable Entity'" do
          @build_params.delete(:name)
          perform_request
          response.status.should == "422 Unprocessable Entity"
        end
      end
    end
  end

  describe "a PUT to update" do
    before(:each) do
      @build = Build.make(:commit_id => @commit.id)
      @new_name = @build.name + " (modified)"
    end

    def perform_request
      put :update, :project_id => @project.to_param, :commit_id => @commit.to_param, :id => @build.to_param, :build => {:name => @new_name}
    end

    context "without passing in valid authentication credentials" do
      it "returns a '401 Unauthorized' response" do
        perform_request
        response.status.should == "401 Unauthorized"
      end
    end

    context "when successfully authenticated" do
      before(:each) do
        setup_basic_auth(@project.public_key, @project.private_key)
      end

      context "when a valid request is made" do
        it "assigns the specified build object for the view template" do
          perform_request
          assigns[:build].should == @build
        end

        it "returns a response code of '200 OK'" do
          perform_request
          response.status.should == "200 OK"
        end

        it "sets the 'Location' header to the build URI" do
          perform_request
          response.headers["Location"].should == api_v1_project_commit_build_url(:xml, @project, @commit, assigns[:build])
        end

        it "saves the supplied values to the specified build" do
          perform_request
          @build.reload.name.should == @new_name
        end
      end

      context "when an invalid request is made" do
        it "returns a response code of '422 Unprocessable Entity'" do
          @new_name = nil
          perform_request
          response.status.should == "422 Unprocessable Entity"
        end
      end
    end
  end

  describe "a DELETE to destroy" do
    before(:each) do
      @build = Build.make(:commit_id => @commit.id)
    end

    def perform_request
      delete :destroy, :project_id => @project.to_param, :commit_id => @commit.to_param, :id => @build.to_param
    end

    context "without passing in valid authentication credentials" do
      it "returns a '401 Unauthorized' response" do
        perform_request
        response.status.should == "401 Unauthorized"
      end
    end

    context "when successfully authenticated" do
      before(:each) do
        setup_basic_auth(@project.public_key, @project.private_key)
      end

      it "returns a response code of '200 OK'" do
        perform_request
        response.status.should == "200 OK"
      end

      context "the specified build exists" do
        it "deletes the build from the database" do
          perform_request
          Build.find_by_id(@build.id).should be_nil
        end
      end

      context "the specified build does not exist" do
        it "behaves idempotently" do
          @build.destroy
          perform_request
          response.status.should == "200 OK"
        end
      end
    end
  end
end
