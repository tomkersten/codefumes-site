require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::PayloadsController do
  before(:each) do
    @request.env["HTTP_ACCEPT"] = "application/xml"
  end

  describe "a POST to create" do
    before(:each) do
      @project = Project.make
      commit_params = 3.times.map {Commit.plan.stringify_keys}
      @payload_params = {"commits" => commit_params, "after" => 'sha1_after', "before" => 'sha1_before'}
    end

    def perform_request
      post :create, :project_id => @project.public_key, :private_key => @project.private_key, :payload => @payload_params
    end

    context "with valid parameters" do
      it "returns a status code of '201 Created'" do
        perform_request
        response.status.should == "201 Created"
      end

      it "creates a new payload" do
        lambda {perform_request}.should change(Payload, :count).by(1)
      end

      it "sets the 'Location' header to the payload's URI" do
        Payload.destroy_all
        perform_request
        payload = Payload.first
        response.headers["Location"].should == api_v1_payload_url(:format => :xml, :id => payload)
      end

      it "returns an XML representation of a Payload" do
        perform_request
        response.should render_template('api/v1/payloads/create.xml.haml')
      end

      it "associates the payload with the specified project" do
        @project.payloads.should be_empty
        perform_request
        payload = Payload.first
        @project.reload.payloads.should include(payload)
      end

      it "serializes the content supplied in the 'payload' param into 'content'" do
        Payload.destroy_all
        perform_request
        payload = Payload.first
        payload.content.should == @payload_params
      end
    end

    context "without a valid public_key of a project" do
      before(:each) do
        Project.destroy_all
      end

      def perform_request
        post :create, :project_id => "non_existant_public_key", :payload => @payload_params
      end

      it "returns a status code of '422 Unprocessable Entity'" do
        perform_request
        response.status.should == '422 Unprocessable Entity'
      end

      it "does not create a new payload" do
        lambda {perform_request}.should_not change(Payload, :count)
      end
    end
    
    context "without a valid private_key of a project" do
      it "returns 401 unauthorized" do
        post :create, :project_id => @project.public_key, :payload => @payload_params
        puts response.status
        response.status.should == "401 Unauthorized"
      end
    end
  end
end
