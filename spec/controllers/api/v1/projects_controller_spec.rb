require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::ProjectsController do
  before(:each) do
    @request.env["HTTP_ACCEPT"] = "application/xml"
  end

  describe "a GET to index" do
    before(:each) do
      @projects = (1..3).map {Project.make}
    end

    def perform_request
      get :index
    end

    it "assigns all projects for the view template" do
      perform_request
      assigns[:projects].should == @projects
    end

    xit "returns a <projects> container tag with a <project> tag for each project" do
      perform_request
      response.should have_tag("projects") do
        with_tag("project", :count => @projects.count)
      end
    end
  end

  describe "a POST to create" do
    def perform_request
      post :create, :project => @params
    end

    context "with valid params" do
      before(:each) do
        @params = Project.plan
      end

      it "creates a project" do
        lambda {
          perform_request
        }.should change(Project, :count).by(1)
      end

      it "set the 'Location' header to the API URI of the created project" do
        perform_request
        project = Project.find_by_name(@params[:name])
        response.headers["Location"].should == api_v1_project_url(:format => :xml, :id => project)
      end
    end

    context "with invalid parameters" do
      before(:each) do
        existing_project = Project.make
        @params = Project.plan.merge(:public_key => existing_project.public_key)
      end

      it "does not set the location header" do
        perform_request
        response.headers["Location"].should  be_nil
      end

      it "returns a 422 Unprocessible entity status code" do
        perform_request
        response.status.should == "422 Unprocessable Entity"
      end
    end
  end

  describe "a GET to show" do
    def perform_request
      get :show, :id => @project.public_key
    end

    context "when the requested resource exists" do
      before(:each) do
        @project = Project.make
      end

      it "assigns the specified project for the view template" do
        perform_request
        assigns[:project].should == @project
      end

      it "returns a response code of 200 OK" do
        perform_request
        response.status.should == "200 OK"
      end
    end

    context "when the requested resource exists" do
      before(:each) do
        Project.destroy_all
        @project = Project.new(Project.plan)
      end

      it "returns a response code of 404 Not Found" do
        perform_request
        response.status.should == "404 Not Found"
      end
    end
  end

  describe "a DELETE to destroy" do
    before(:each) do
      @project = Project.make
      setup_basic_auth(@project.public_key, @project.private_key)
    end

    def perform_request
      delete :destroy, :id => @project.public_key
    end

    it "deletes the specified project" do
      perform_request
      Project.find_by_id(@project.id).should be_nil
    end

    it "returns a response code of 200 OK" do
      perform_request
      response.should be_success
    end

    context "when the resource does not exist" do
      before(:each) do
        Project.destroy_all
      end

      it "returns a response code of 200 OK" do
        perform_request
        response.should be_success
      end
    end
    
    context "with invalid private key" do
      it "returns 401 unauthorized" do
        setup_basic_auth('some', 'garbage')
        delete :destroy, :id => @project.public_key
        response.status.should == "401 Unauthorized"
      end
    end
  end

  describe "a PUT to update" do
    before(:each) do
      @project = Project.make
      @public_key = @project.public_key
      setup_basic_auth(@project.public_key, @project.private_key)
    end

    def perform_request
      put :update, :id => @public_key, :project => @update_params
    end

    context "with valid parameters" do
      before(:each) do
        @update_params = Project.plan
      end

      context "for an existing public_key" do
        it "returns a response code of 200 OK" do
          perform_request
          response.should be_success
        end

        it "updates the specified project with the supplied values" do
          perform_request
          @project.reload
          @project.name.should == @update_params[:name]
        end

        it "does not update the public_key" do
          original_public_key = @project.public_key
          perform_request
          @project.reload
          @project.public_key.should == original_public_key
        end

        it "does not update the private_key" do
          @update_params[:private_key] = @project.private_key
          original_private_key = @project.private_key
          perform_request
          @project.reload
          @project.private_key.should == original_private_key
        end
      end
    end

    context "with invalid parameters" do
      before(:each) do
        @public_key = "non-existant-public-key"
      end

      it "returns a response code of 422 Unprocessable Entity" do
        perform_request
        response.status.should == "422 Unprocessable Entity"
      end

      it "does not set a value for the 'Location' header" do
        perform_request
        response.headers["Location"].should  be_nil
      end
    end
    
    context "with invalid private key" do
      it "returns 401 unauthorized" do
        setup_basic_auth('some', 'garbage')
        put :update, :id => @project.public_key, :project => @update_params
        response.status.should == "401 Unauthorized"
      end
    end
  end
end

