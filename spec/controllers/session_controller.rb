require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionController do
  context "a GET to new" do
    it "loads a user session for the view template" do
      get :new
      assigns(:user_session).should_not be_nil
    end
  end

  context "a GET to confirm_logout" do
    it "renders the confirm_logout view template" do
      get :confirm_logout
      response.should render_template('session/confirm_logout')
    end
  end

  context "a DELETE to destroy" do
    before(:each) do
      @user_session = mock_model(UserSession, :destroy => true).as_null_object
      controller.stub!(:current_user_session).and_return(@user_session)
    end

    def perform_request
      delete :destroy
    end

    it "destroys the user's session" do
      @user_session.should_receive(:destroy)
      perform_request
    end

    it "redirects to the login path" do
      perform_request
      response.should redirect_to(login_path)
    end
  end

  context "a POST to create" do
    before(:each) do
      controller.stub!(:current_user_session).and_return(nil)
      @user_session = mock("New UserSession").as_null_object
      @request_params = mock("Params for new UserSession")
      UserSession.stub!(:new).with(@request_params).and_return(@user_session)
    end

    def perform_request
      post :create, :user_session => @request_params
    end

    it "should save a new user session" do
      @user_session.should_receive(:save).and_return(true)
      perform_request
      assigns(:user_session).should == @user_session
    end

    context "with valid credentials" do
      before(:each) do
        @user_session.stub!(:save).and_return(true)
      end

      it "redirects to the home page" do
        perform_request
        response.should redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      before(:each) do
        @user_session.stub!(:save).and_return(false)
      end

      it "assigns an error for the view template" do
        perform_request
        flash[:error].should_not be_nil
      end

      it "renders the login form" do
        perform_request
        response.should render_template('session/new')
      end
    end
  end
end
