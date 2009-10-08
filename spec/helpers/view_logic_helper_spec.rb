require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ViewLogicHelper do
  describe "priveleged_user_or_owner_content" do
    before(:each) do
      @user = User.make(:dora)
      helper.stub!(:current_user).and_return(@user)
    end

    context "when the user is logged in" do
      before(:each) do
        helper.stub!(:logged_in?).and_return(true)
      end

      it "does not yield when the content passed in is nil" do
        output = helper.priveleged_user_or_owner_content(nil) {"it yielded"}
        output.should be_nil
      end

      it "yields when the user is logged in and the user owns the specified content" do
        @owned_content = mock("User-owned content", :owner => @user)
        block_content = "it yielded"
        output = helper.priveleged_user_or_owner_content(@owned_content) {block_content}
        output.should == block_content
      end
    end

    context "when the user is not logged in" do
      before(:each) do
        helper.stub!(:logged_in?).and_return(false)
      end

      it "does not yield to the supplied block" do
        output = helper.priveleged_user_or_owner_content {"it yielded"}
        output.should be_nil
      end
    end
  end

  describe "non_paying_user_content" do
    before(:each) do
      @yielded_content = "it yielded"
      helper.stub!(:current_user).and_return(@user)
    end

    context "when logged in" do
      before(:each) do
        helper.stub!(:logged_in?).and_return(true)
      end

      it "yields when the user is not a paying customer" do
        @user = User.make(:oscar)
        helper.stub!(:current_user).and_return(@user)
        results = helper.non_paying_user_content {@yielded_content}
        results.should == @yielded_content
      end

      it "does not yields when the user is a paying customer" do
        @user = Subscription.make(:doras).user
        helper.stub!(:current_user).and_return(@user)
        results = helper.non_paying_user_content {@yielded_content}
        results.should be_nil
      end
    end

    context "when not logged in" do
      before(:each) do
        helper.stub!(:logged_in?).and_return(false)
      end

      it "yields the specified block" do
        output = helper.non_paying_user_content {@yielded_content}
        output.should  == @yielded_content
      end
    end
  end

  describe "paying_user_content" do
    before(:each) do
      @yielded_content = "it yielded"
      helper.stub!(:current_user).and_return(@user)
    end

    context "when logged in" do
      before(:each) do
        helper.stub!(:logged_in?).and_return(true)
      end

      it "does not yield when the user is not a paying customer" do
        @user = User.make(:oscar)
        helper.stub!(:current_user).and_return(@user)
        results = helper.paying_user_content {@yielded_content}
        results.should be_nil
      end

      it "yields when the user is a paying customer" do
        @user = Subscription.make(:doras).user
        helper.stub!(:current_user).and_return(@user)
        results = helper.paying_user_content {@yielded_content}
        results.should == @yielded_content
      end
    end

    context "when not logged in" do
      before(:each) do
        helper.stub!(:logged_in?).and_return(false)
      end

      it "yields the specified block" do
        output = helper.paying_user_content {@yielded_content}
        output.should be_nil
      end
    end
  end
end
