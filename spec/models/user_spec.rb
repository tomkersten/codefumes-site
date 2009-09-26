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

  describe "handle" do
    it "returns the value which will be used for 'identification' of a user across the site" do
      user = User.make
      user.handle.should == user.email
    end
  end
end
