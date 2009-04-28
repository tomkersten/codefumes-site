require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  before(:each) do
    @user = mock_model(User)
  end

  context "a GET to new" do
    it "assigns a user object for the view template" do
      User.stub!(:new).and_return(@user)
      get :new
      assigns(:user).should == @user
    end
  end

  context "a POST to create" do
    before(:each) do
      @user_params = mock("Params for new user")
      User.stub!(:new).with(@user_params).and_return(@user)
      @user.stub!(:save)
    end

    def perform_request
      post :create, :user => @user_params
    end

    it "initializes a new user object with the supplied parameters" do
      perform_request
      assigns(:user).should == @user
    end

    it "saves the user object" do
      @user.should_receive(:save)
      perform_request
    end

    context "with valid attributes" do
      before(:each) do
        @user.stub!(:save).and_return(true)
      end

      it "redirects to the home page" do
        perform_request
        response.should redirect_to(root_path)
      end

      it "sets a notification for the view template" do
        perform_request
        flash[:notice].should_not be_nil
      end
    end

    context "with invalid attributes" do
      before(:each) do
        @user.stub!(:save).and_return(false)
      end

      it "renders the signup form again" do
        perform_request
        response.should render_template('users/new')
      end

      it "sets an error message for the view template" do
        perform_request
        flash[:error].should_not be_nil
      end
    end
  end

end
