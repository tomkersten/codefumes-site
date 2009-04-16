require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe User do
  context "deliver_password_reset_instructions!" do
    before(:each) do
      @typical_user = Factory(:typical_user)
    end

    it "resets the user's perishable token" do
      @typical_user.should_receive(:reset_perishable_token!)
      @typical_user.deliver_password_reset_instructions!
    end

    it "sends an email to the user with instructions on how to reset their password" do
      Notifier.should_receive(:deliver_password_reset_instructions).with(@typical_user)
      @typical_user.deliver_password_reset_instructions!
    end
  end
end
