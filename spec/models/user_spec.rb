require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe User do
  describe "deliver_password_reset_instructions!" do
    before(:each) do
      @typical_user = User.make(:typical_user)
    end

    it "resets the user's perishable token" do
      pending "Investigate when users are enabled"
      @typical_user.should_receive(:reset_perishable_token!)
      @typical_user.deliver_password_reset_instructions!
    end

    it "sends an email to the user with instructions on how to reset their password" do
      pending "Investigate when users are enabled"
      Notifier.should_receive(:deliver_password_reset_instructions).with(@typical_user)
      @typical_user.deliver_password_reset_instructions!
    end
  end
  
  describe "claim" do
    before(:each) do
      @project = Project.make
      @typical_user = User.make(:typical_user)
      @project.owner.should be_nil
      @typical_user.projects.should be_empty
      @project.visibility.should == Project::PUBLIC
    end
    context "without specifiying visibility" do
      before(:each) do
        @typical_user.claim(@project).should be_true
      end
      it "sets the user on the project" do
        @project.owner.should == @typical_user
        @typical_user.projects.should include(@project)
      end
      it "doesn't change the project's visibility" do
        @project.visibility.should == Project::PUBLIC
      end
    end
    
    context "when specifying visibility" do
      context "valid visibility" do
        before(:each) do
          @typical_user.claim(@project, Project::PRIVATE).should be_true
        end
        it "sets the user on the project" do
          @project.owner.should == @typical_user
          @typical_user.projects.should include(@project)
        end
        it "changes the project's visibility" do
          @project.visibility.should == Project::PRIVATE
        end
      end
      context "invalid visibility" do
        before(:each) do
          @typical_user.claim(@project, 'some crap').should be_false
        end
        it "doen't set the user on the project" do
          @project.owner.should_not == @typical_user
          @typical_user.projects.should_not include(@project)
        end
        it "doesn't change the project's visibility" do
          @project.visibility.should == Project::PUBLIC
        end
      end
    end
  end
  
  describe "relinquish_claim" do
    before(:each) do
      @project = Project.make
      @typical_user = User.make(:typical_user)
      @project.owner.should be_nil
      @typical_user.projects.should be_empty
      @project.visibility.should == Project::PUBLIC
    end
    context "unclaimed project" do
      it "doesn't do anything" do
        @typical_user.relinquish_claim(@project).should be_true
        @project.owner.should be_nil
        @typical_user.projects.should be_empty
      end
    end
    context "project owned by user" do
      before(:each) do
        @typical_user.claim(@project, Project::PRIVATE).should be_true
        @typical_user.relinquish_claim(@project).should be_true
      end
      it "removes the user from the project" do
        @project.owner.should be_nil
        @typical_user.projects.should be_empty
      end
      it "resets the status to public" do
        @project.visibility.should == Project::PUBLIC
      end
    end
    context "project owned by other user" do
      before(:each) do
        @another_user = User.make(:typical_user)
        @another_user.claim(@project, Project::PRIVATE).should be_true
      end
      it "doesn't do anything" do
        @typical_user.relinquish_claim(@project).should be_true
        @project.owner.should == @another_user
        @typical_user.projects.should be_empty
        @another_user.projects.should include(@project)
        @project.visibility.should == Project::PRIVATE
      end
    end
  end

  describe "handle" do
    it "returns the value which will be used for 'identification' of a user across the site" do
      user = User.make
      user.handle.should == user.login
    end
  end

  describe "paying_customer?" do
    before(:each) do
      @user = Subscription.make(:doras).user
    end

    it "returns false when the user's most recent subscription is not in a 'confirmed' state" do
      @user.subscriptions.should_not be_empty
      @user.paying_customer?.should == false
    end

    it "returns false when the user does not have any subscriptions" do
      @user.subscriptions.destroy_all
      @user.paying_customer?.should == false
    end

    it "returns true when the user most recent subscription is in a 'confirmed' state" do
      @user.subscriptions.last.confirm!
      @user.paying_customer?.should == true
    end
  end

  describe "current_subscription" do
    before(:each) do
      @user = User.make(:dora)
      @subscription = Subscription.make(:basic, :user => @user)
    end

    context "when the most recent subscription is confirmed" do
      it "returns said subscription" do
        @subscription.confirm!
        @user.current_subscription.should == @subscription
      end
    end

    context "when the most recent subscription is cancelled" do
      it "returns nil" do
        @subscription.confirm!
        @subscription.cancel!
        @user.current_subscription.should be_nil
      end
    end

    context "when the most recent subscription is unconfirmed" do
      context "and the user does not have any 'confirmed' subscriptions" do
        it "returns nil" do
          @user.current_subscription.should be_nil
        end
      end
    end
  end
end
