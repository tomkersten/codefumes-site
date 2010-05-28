require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe My::AccountController do
  let(:user) {User.make(:dora)}

  before(:each) do
    controller.stub!(:current_user).and_return(user)
  end

  describe "a GET to #show" do
    it "assigns the current user to user for the view template" do
      get :show
      assigns[:user].should == user
    end
  end

  describe "a PUT to #update" do
    let(:supplied_params) {{"password" => "pw", "password_confirmation" => "pw"}}

    def perform_request
      put :update, :user => supplied_params
    end

    it "redirects to the account overview page" do
      perform_request
      response.should redirect_to(my_account_path)
    end

    it "updates the user account" do
      user.should_receive(:update_attributes).with(supplied_params)
      perform_request
    end

    it "notifies the user with a message that their account was updated" do
      perform_request
      flash[:notice].should_not be_nil
    end
  end
end
