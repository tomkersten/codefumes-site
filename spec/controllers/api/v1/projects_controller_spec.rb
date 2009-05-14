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

  describe "POST to create" do
    describe "with valid params" do
      before(:each) do
        @params = Project.plan
      end

      def perform_request
        post :create, :project => @params
      end

      it "creates a project" do
        lambda {
          perform_request
        }.should change(Project, :count).by(1)
      end

      it "set the 'Location' header to the API URI of the created project" do
        perform_request
        project = Project.find_by_public_key(@params[:public_key])
        response.headers["Location"].should == api_v1_project_url(:format => :xml, :id => project)
      end
    end
  end

  describe "a GET to show" do
    before(:each) do
      @project = Project.make
    end

    it "assigns the specified project for the view template" do
      get :show, :id => @project.id
      assigns[:project].should == @project
    end
  end
end
