require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe User do
  context "deliver_password_reset_instructions!" do
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
      @project.user.should be_nil
      @typical_user.projects.should be_empty
      @project.visibility.should == Project::PUBLIC
    end
    context "without specifiying visibility" do
      before(:each) do
        @typical_user.claim(@project).should be_true
      end
      it "sets the user on the project" do
        @project.user.should == @typical_user
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
          @project.user.should == @typical_user
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
          @project.user.should_not == @typical_user
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
      @project.user.should be_nil
      @typical_user.projects.should be_empty
      @project.visibility.should == Project::PUBLIC
    end
    context "unclaimed project" do
      it "doesn't do anything" do
        @typical_user.relinquish_claim(@project).should be_true
        @project.user.should be_nil
        @typical_user.projects.should be_empty
      end
    end
    context "project owned by user" do
      before(:each) do
        @typical_user.claim(@project, Project::PRIVATE).should be_true
        @typical_user.relinquish_claim(@project).should be_true
      end
      it "removes the user from the project" do
        @project.user.should be_nil
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
        @project.user.should == @another_user
        @typical_user.projects.should be_empty
        @another_user.projects.should include(@project)
        @project.visibility.should == Project::PRIVATE
      end
    end
  end

  describe "handle" do
    it "returns the value which will be used for 'identification' of a user across the site" do
      user = User.make
      user.handle.should == user.email
    end
  end
end
