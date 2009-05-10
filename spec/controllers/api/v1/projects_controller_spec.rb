require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::ProjectsController do
  before(:each) do
    @request.env["HTTP_ACCEPT"] = "application/xml"
  end

  context "in V1 of the XML API" do
    describe "a GET to /projects" do
      before(:each) do
        @projects = (1..3).map {Project.make}
      end

      it "returns a <projects> container tag with a <project> tag for each project" do
        get :index
        response.should have_tag("projects") do
          with_tag("project", :count => @projects.count)
        end
      end
    end

    describe "POST create" do
      describe "with valid params" do
        def perform_request
          post :create, :project => Project.plan
        end

        it "creates a project" do
          lambda {
            perform_request
          }.should change(Project, :count).by(1)
        end

        it "redirects to the created project" do
          perform_request
          response.should have_tag("project")
        end
      end
    end
  end
end
