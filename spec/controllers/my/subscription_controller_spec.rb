require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe My::SubscriptionController do
  before(:each) do
    @user = User.make(:dora)
    controller.stub!(:current_user).and_return(@user)
  end

  context "a GET to new" do
    it "loads the plans visible to the public" do
      basic_plan = Plan.make(:basic)
      custom_plan = Plan.make(:custom)
      get :new
      assigns[:visible_plans].should == [basic_plan]
    end

    it "assigns a subscription for the view template" do
      get :new
      assigns[:subscription].should_not be_nil
    end
  end

  context "a POST to create" do
    def perform_request(options = {})
      post :create, :subscription => Subscription.plan.merge(options)
    end

    context "with valid parameters" do
      it "redirects to the confirmation page" do
        perform_request
        response.should redirect_to(confirm_my_subscription_path)
      end

      it "should associate an 'unconfirmed' subscription with the user" do
        @user.reload.subscriptions.unconfirmed.should be_empty
        perform_request
        @user.reload.subscriptions.unconfirmed.should have(1).subscription
      end
    end

    context "when passing in the plan_id of a 'non-public' plan" do
      before(:each) do
        @hidden_plan = Plan.make(:custom)
      end

      it "notifies the user of an error"
      it "re-renders the subscription form"
    end
  end

  context "a GET to confirm" do
    it "loads the users most recent unconfirmed subscription for the view template" do
      first = Subscription.make(:basic, :user => @user)
      second= Subscription.make(:basic, :user => @user)
      get :confirm
      assigns[:subscription].should == second
    end
  end

  context "a PUT to confirmed" do
    before(:each) do
      @first  = Subscription.make(:basic, :user => @user)
      @second = Subscription.make(:basic, :user => @user)
    end

    it "marks the most recent unconfirmed subscription as 'confirmed'" do
      put :confirmed
      @first.reload.state.should == "unconfirmed"
      @second.reload.state.should == "confirmed"
    end

    it "notifies the user that the action was successful" do
      put :confirmed
      flash[:notice].should_not be_nil
    end

    it "redirects the user back to their list of projects" do
      put :confirmed
      response.should redirect_to(my_projects_path)
    end
  end

  context "a GET to edit" do
    before(:each) do
      custom_plan = Plan.make(:custom)
      @basic_plan = Plan.make(:basic)
      @subscription = Subscription.make(:basic, :user => @user, :plan => @basic_plan)
      @subscription.confirm!
    end

    it "loads the plans visible to the public" do
      get :edit
      assigns[:visible_plans].should == [@basic_plan]
    end

    it "assigns a subscription for the view template" do
      get :edit
      assigns[:subscription].should_not be_nil
    end
  end

  context "a PUT to cancelled" do
    before(:each) do
      @subscription = Subscription.make(:basic, :user => @user)
      @subscription.confirm!
    end

    it "marks the most recent confirmed subscription as 'cancelled'" do
      put :cancelled
      @subscription.reload.state.should == "cancelled"
    end

    it "notifies the user that the action was successful" do
      put :cancelled
      flash[:notice].should_not be_nil
    end

    it "redirects the user back to their list of projects" do
      put :cancelled
      response.should redirect_to(my_projects_path)
    end
  end
end
