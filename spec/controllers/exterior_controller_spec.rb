require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExteriorController do
  describe "GET 'index'" do
    def perform_request
      get 'index'
    end

    it "is successful" do
      perform_request
      response.should be_success
    end

    it "assigns a project key for the view template" do
      perform_request
      assigns(:public_key).should_not be_nil
    end
  end
end
