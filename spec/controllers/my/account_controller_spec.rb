require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe My::AccountController do
  before(:each) do
    @user = User.make(:dora)
    controller.stub!(:current_user).and_return(@user)
  end

  describe "a GET to show" do
    it "assigns the current user to @user for the view template" do
      get :show
      assigns[:user].should == @user
    end
  end
end
