require File.dirname(__FILE__) + '/../spec_helper'

describe Notifier do
  include ActionController::UrlWriter
  before(:each) do
    @host = "example.com"
  end

  before(:all) do
    @user = User.new(:login => "user_1", :password => "tester", :password_confirmation => "password", :email => "jdoe@example.com")
  end

  context "emailing password reset instructions" do
    before(:each) do
      @notification = Notifier.create_password_reset_instructions(@user)
    end

    subject {@notification}

    it "delivers the message to the supplied user's email" do
      pending "Investigate after users introduced (see ben mabey's email spec)"
      should deliver_to(@user.email)
    end

    it "should contain a link to the confirmation page" do
      pending "Investigate after users introduced (see ben mabey's email spec)"
      should have_body_text(/#{edit_support_password_reset_request_url(:host => @host)}/)
    end
  end
end
