require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Support::PasswordResetRequestController do
  before(:each) do
    @user = mock_model(User, :email => "jdoe@example.com")
  end

  shared_examples_for "Any perishable token request" do
    it "looks up the user using the supplied perishable token" do
      User.should_receive(:find_using_perishable_token).with(@token)
      perform_request
    end
  end

  shared_examples_for "Any invalid perishable token request" do
    it "redirects to the home page" do
      perform_request
      response.should redirect_to(root_path)
    end

    it "notifies the user that their request failed" do
      perform_request
      flash[:error].should_not be_nil
    end
  end

  context "a GET to new" do
    it "renders the 'new' template" do
      get :new
      response.should render_template('support/password_reset_request/new')
    end
  end

  context "a POST to create" do
    def make_request
      post :create, :user => {:email => @user.email}
    end

    context "with an email that exists in the system" do
      before(:each) do
        User.stub!(:find_by_email).with(@user.email).and_return(@user)
        @user.stub!(:deliver_password_reset_instructions!)
      end

      it "delivers the password reset instructions to the user" do
        @user.should_receive(:deliver_password_reset_instructions!)
        make_request
      end

      it "redirects to the home page" do
        make_request
        response.should redirect_to(root_path)
      end

      it "notifies the user to check their email" do
        make_request
        flash[:notice].should_not be_nil
      end
    end

    context "with an email that does not exist in the system" do
      before(:each) do
        User.stub!(:find_by_email).and_return(nil)
      end

      it "notifies the user that the email does not exist" do
        make_request
        flash[:error].should_not be_nil
      end

      it "renders the password reset request form again" do
        make_request
        response.should render_template('support/password_reset_request/new')
      end
    end
  end

  context "a GET to edit" do
    before(:each) do
      @token = mock("User's perishable token")
    end

    def perform_request
      get :edit, :id => @token
    end

    it_should_behave_like "Any perishable token request"

    context "with a valid token" do
      before(:each) do
        User.stub!(:find_using_perishable_token).and_return(@user)
      end

      it "renders the reset password form" do
        perform_request
        response.should render_template('support/password_reset_request/edit')
      end
    end

    context "with an invalid token" do
      before(:each) do
        User.stub!(:find_using_perishable_token).and_return(nil)
      end
      it_should_behave_like "Any invalid perishable token request"
    end
  end

  context "a PUT to update" do
    def perform_request
      put :update, :id => @token, :user => {:password => @password, :password_confirmation => @password}
    end

    context "with a valid token" do
      before(:each) do
        @token = mock("User's perishable token")
        @password = mock("The password the user supplied")
        User.stub!(:find_using_perishable_token).with(@token).and_return(@user)
        @user.stub!(:save)
        @user.stub!(:password=).with(@password)
        @user.stub!(:password_confirmation=).with(@password)
      end

      it "updates the user's password with the supplied information" do
        @user.should_receive(:password=).with(@password)
        @user.should_receive(:password_confirmation=).with(@password)
        perform_request
      end

      it "saves the user" do
        @user.should_receive(:save)
        perform_request
      end

      context "and password" do
        before(:each) do
          @user.stub!(:save).and_return(true)
        end

        it "notifies them that their password was updated" do
          perform_request
          flash[:notice].should_not be_nil
        end

        it "redirects back to the home page" do
          perform_request
          response.should redirect_to(root_path)
        end
      end

      context "but an invalid password" do
        before(:each) do
          @user.stub!(:save).and_return(false)
        end

        it "notifies them that their password was updated" do
          perform_request
          flash[:error].should_not be_nil
        end

        it "renders the reset password form" do
          perform_request
          response.should render_template('support/password_reset_request/edit')
        end
      end
    end

    context "with an invalid token" do
      before(:each) do
        User.stub!(:find_using_perishable_token).and_return(nil)
      end

      it_should_behave_like "Any invalid perishable token request"

      it "does not update the password or save the user" do
        @user.should_not_receive(:password)
        @user.should_not_receive(:password_confirmation)
        @user.should_not_receive(:save)
        perform_request
      end
    end
  end
end
