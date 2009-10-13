require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe User do
  describe "deliver_password_reset_instructions!" do
    before(:each) do
      @user = User.make(:typical_user)
    end

    it "resets the user's perishable token" do
      pending "Investigate when users are enabled"
      @user.should_receive(:reset_perishable_token!)
      @user.deliver_password_reset_instructions!
    end

    it "sends an email to the user with instructions on how to reset their password" do
      pending "Investigate when users are enabled"
      Notifier.should_receive(:deliver_password_reset_instructions).with(@user)
      @user.deliver_password_reset_instructions!
    end
  end

  describe "claim" do
    before(:each) do
      @project = Project.make
      @user = Subscription.make(:doras).user
      @project.owner.should be_nil
      @user.projects.should be_empty
      @project.visibility.should == Project::PUBLIC
    end

    context "without specifiying visibility" do
      before(:each) do
        @user.claim(@project).should be_true
      end

      it "sets the user on the project" do
        @project.owner.should == @user
        @user.projects.should include(@project)
      end

      it "doesn't change the project's visibility" do
        @project.visibility.should == Project::PUBLIC
      end
    end

    context "when specifying visibility" do
      context "valid visibility" do
        before(:each) do
          @user.claim(@project, Project::PRIVATE).should be_true
        end

        it "sets the user on the project" do
          @project.owner.should == @user
          @user.projects.should include(@project)
        end

        it "changes the project's visibility" do
          @project.visibility.should == Project::PRIVATE
        end
      end

      context "invalid visibility" do
        before(:each) do
          @user.claim(@project, 'some crap').should be_false
        end

        it "doen't set the user on the project" do
          @project.owner.should_not == @user
          @user.projects.should_not include(@project)
        end

        it "doesn't change the project's visibility" do
          @project.visibility.should == Project::PUBLIC
        end
      end
    end

    context "a new private projects" do
      before(:each) do
        @project = Project.make(:public)
      end

      it "sets the value of 'privatized_at' to the current time" do
        cached_time = Time.now
        Time.stub!(:now).and_return(cached_time)

        @project.privatized_at.should be_nil

        @user.claim(@project, "private").should be_true
        @project.privatized_at.should == cached_time
      end

      context "when the user has not reached their plan's limit of projects" do
        it "they can make a private claim" do
          @user.claim(@project, "private").should be_true
        end
      end
    end
  end

  describe "relinquish_claim" do
    before(:each) do
      @project = Project.make
      @user = Subscription.make(:doras).user
      @project.owner.should be_nil
      @user.projects.should be_empty
      @project.visibility.should == Project::PUBLIC
    end

    context "unclaimed project" do
      it "doesn't do anything" do
        @user.relinquish_claim(@project).should be_true
        @project.owner.should be_nil
        @user.projects.should be_empty
      end
    end

    context "project owned by user" do
      before(:each) do
        @user.claim(@project, Project::PRIVATE).should be_true
      end

      it "removes the user from the project" do
        @user.relinquish_claim(@project).should be_true
        @project.owner.should be_nil
        @user.projects.should be_empty
      end

      it "resets the status to public" do
        @user.relinquish_claim(@project)
        @project.visibility.should == Project::PUBLIC
      end

      it "sets the value of 'privatized_at' to nil" do
        @project.privatized_at.should_not be_nil
        @user.relinquish_claim(@project).should be_true
        @project.reload
        @project.privatized_at.should be_nil
      end
    end

    context "project owned by other user" do
      before(:each) do
        @another_user = User.make(:typical_user)
        Subscription.make(:confirmed, :user => @another_user)
        @another_user.claim(@project, Project::PRIVATE).should be_true
      end

      it "doesn't do anything" do
        @user.relinquish_claim(@project).should be_true
        @project.owner.should == @another_user
        @user.projects.should be_empty
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
      @user = Subscription.make(:doras, :state => "unconfirmed").user
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

  describe "covered_projects" do
    before(:each) do
      @user = User.make(:dora)
      @public = Project.make(:public)
    end

    context "when the user has no claimed projects" do
      it "returns an empty Array" do
        @user.covered_projects.should be_empty
      end
    end

    context "when the user has only claimed 'public' projects" do
      before(:each) do
        @user.claim(@public, "public")
      end

      it "returns an empty Array (public projects aren't covered, they're free)" do
        @user.covered_projects.should be_empty
      end
    end

    context "when the user has a subscription and has claimed private projects" do
      before(:each) do
        Subscription.make(:confirmed, :user_id => @user.id).user.should == @user
        @inside_subscription  = Project.make(:private)
        @outside_subscription = Project.make(:private)
        @user.claim(@inside_subscription)
        @user.claim(@outside_subscription)
        @inside_subscription.update_attribute(:privatized_at, 8.days.ago.utc)
      end

      it "returns the projects claimed which fall inside their plan limit" do
        @user.covered_projects.should include(@inside_subscription)
      end

      it "excludes the projects claimed which fall outside their plan limit" do
        @user.covered_projects.should_not include(@outside_subscription)
      end
    end
  end
end
