require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Community::ProjectsController do
  describe "a get to show" do
    before(:each) do
      (1..2).each {Project.make}
      @project = Project.make
      (1..2).each {Project.make}
    end

    it "assigns the requested project for the view template" do
      get :show, :id => @project.id
      assigns[:project].should == @project
    end
  end

  describe "a GET to short_uri" do
    context "with a non-existant public key" do
      before(:each) do
        Project.destroy_all
        @public_key = Project.generate_public_key
      end

      it "renders the 'short_uri' view" do
        get :short_uri, :public_key => @public_key
        response.should render_template('community/projects/short_uri')
      end
    end

    context "with a public key of an existing project" do
      before(:each) do
        @project = Project.make
      end

      it "redirects to the project's community page" do
        get :short_uri, :public_key => @project.public_key
        response.should redirect_to(community_project_path(@project))
      end
    end
  end
end
