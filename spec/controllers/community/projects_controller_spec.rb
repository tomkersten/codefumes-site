require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Community::ProjectsController do
  describe "a get to show" do
    before(:each) do
      Project.make
      @project = Project.make
      Project.make
    end

    it "assigns the requested project for the view template" do
      get :show, :id => @project.public_key
      assigns[:project].should == @project
    end
  end

  describe "a GET to short_uri" do
    context "with a non-existant public key" do
      it "redirects the user to the 'non-existant project' page" do
        get :short_uri, :public_key => "non_existant_key"
        response.should redirect_to(invalid_project_path)
      end
    end

    context "with a public key of an existing project" do
      let(:project) {Project.make}

      it "assigns the project with the specified public key for the view template" do
        get :short_uri, :public_key => project.to_param
        assigns[:project].should == project
      end
    end
  end

  describe "a GET to acknowledge" do
    let(:project) {Project.make(:acknowledged_at => nil)}

    def perform_request
      get :acknowledge, :id => project.to_param
    end

    it "marks the project as 'acknowledged'" do
      perform_request
      assigns[:project].visibility_acknowledged?.should be_true
    end

    it "renders the short_uri view of the project page" do
      perform_request
      response.should redirect_to(short_uri_path(project))
    end
  end
end
