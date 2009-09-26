require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExteriorController do
  before(:each) {activate_authlogic}

  describe "GET 'index'" do
    def perform_request
      get :index
    end

    context "when not logged in" do
      it "assigns a project key for the view template" do
        perform_request
        assigns(:public_key).should_not be_nil
      end
    end

    context "when logged in" do
      it "redirects to the users project listing page" do
        login_as :dora
        perform_request
        response.should redirect_to(my_projects_path)
      end
    end
  end
end
