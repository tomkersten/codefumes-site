require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
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

  describe "a GET to 'show'" do
    context "when passed in just a :template_name (from the route)"
    it "renders the template passed in as the 'id' parameter" do
      get :show, :template_name => 'about'
      response.should render_template('pages/about')
    end

    context "when passed in a :dir parameter (done via the route automatically)" do
      it "supports nested pages" do
        get :show, :template_name => 'ci-setup', :dir => 'docs'
        response.should render_template('pages/docs/ci-setup')
      end
    end
  end
end
