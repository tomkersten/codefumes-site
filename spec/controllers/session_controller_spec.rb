require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionController do
  describe "a GET to new" do
    it "assigns a user_session object for the view template" do
      get :new
      assigns(:user_session).should_not be_nil
    end
  end

  describe "a POST to create" do
    before(:each) do
      @password = "password"
      @user = User.make(:password => @password)
    end

    context "with valid parameters" do
      it "redirects to the root path URI" do
        post :create, :user_session => {:login => @user.login, :password => @password}
        response.should redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      it "renders the login form again" do
        post :create, :user_session => {:login => @user.login, :password => @password.reverse}
        response.should render_template('session/new')
      end

      it "notifies the user of the login error" do
        post :create, :user_session => {:login => @user.login, :password => @password.reverse}
        flash[:error].should_not be_nil
      end
    end
  end

  describe "a DELETE to destroy" do
    before(:each) do
      @user_session = mock_model(UserSession).as_null_object
      controller.stub!(:current_user_session).and_return(@user_session)
    end

    it "removes the user session" do
      @user_session.should_receive(:destroy)
      delete :destroy
    end

    it "redirects to the login page" do
      delete :destroy
      response.should redirect_to(login_path)
    end
  end
end
