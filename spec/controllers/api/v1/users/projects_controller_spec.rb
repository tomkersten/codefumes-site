require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe Api::V1::Users::ProjectsController do
  let(:user) {User.make(:dora)}

  before(:each) do
    @request.env["HTTP_ACCEPT"] = "application/xml"
  end

  describe "a GET to index" do
    def perform_request
      get :index, :user_id => user.login
    end


    context "with valid parameters" do
      it "returns a status code of '200 OK'" do
        perform_request
        response.status.should == "200 OK"
      end

      it "returns an XML representation of a Payload" do
        perform_request
        response.should render_template('api/v1/projects/index.xml.haml')
      end


      it "loads all the specified user's public projects" do
        public_projects = 2.times.map {Project.make(:owner => user, :visibility => 'public')}
        Project.make(:owner => user, :visibility => 'private')
        Project.make # extra project not owned by user...testing scoping
        user.projects.private.should_not be_empty #confirm test setup
        perform_request
        assigns[:projects].should == public_projects
      end
    end
  end
end
