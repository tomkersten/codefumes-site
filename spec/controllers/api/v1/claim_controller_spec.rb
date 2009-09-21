require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::ClaimController do
  
  before(:each) do
    @project = Project.make
    @user = User.make
    @params = {:project_id => @project.public_key}
    setup_basic_auth(@project.public_key, @project.private_key)
  end
  
  describe "a POST to create" do
    
    context "with invalid project credentials" do
      before(:each) do
        setup_basic_auth("some", "garbage")
      end
      it "returns 401 unauthorized" do
        post :create, @params
        response.status.should == "401 Unauthorized"
      end
      it "doesn't change the user on the project" do
        post :create, @params
        @project.reload.user.should_not == @user
      end
    end
    
    context "with valid project credentials" do
      before(:each) do
        setup_basic_auth(@project.public_key, @project.private_key)
      end
      context "with a valid api_key" do
        before(:each) do
          @params.merge!(:api_key => @user.single_access_token)
        end
        context "for an unclaimed project" do
          it "sets the user on the project" do
            post :create, @params
            @project.reload.user.should == @user
          end
          it "returns a response of created" do
            post :create, @params
            response.status.should == "201 Created"
          end
        end
        
        context "for a previously claimed project" do
          before(:each) do
            @project.user = User.make
            @project.save!
          end
          it "returns 401 unauthorized" do
            post :create, @params
            response.status.should == "401 Unauthorized"
          end
          it "doesn't change the user on the project" do
            post :create, @params
            @project.reload.user.should_not == @user
          end
        end  
      end
      context "with an invalid api_key" do
        before(:each) do
          @params.merge!(:api_key => @user.single_access_token + "some junk")
        end
        it "returns 401 unauthorized" do
          post :create, @params
          response.status.should == "401 Unauthorized"
        end
        it "doesn't change the user on the project" do
          post :create, @params
          @project.reload.user.should_not == @user
        end
      end
    

    end
    
    
  end

  describe "DELETE to 'destroy'" do
    before(:each) do
      @project.user = @user
      @project.save!
    end
    context "with invalid project credentials" do
      before(:each) do
        setup_basic_auth("some", "garbage")
      end
      it "returns 401 unauthorized" do
        delete :destroy, @params
        response.status.should == "401 Unauthorized"
      end
      it "doesn't change the user on the project" do
        delete :destroy, @params
        @project.reload.user.should == @user
      end
    end
    context "with a valid api_key" do
      before(:each) do
        @params.merge!(:api_key => @user.single_access_token)
      end
      context "for an unclaimed project" do
        before(:each) do
          @project.update_attribute(:user,nil)
        end
        it "returns a response of created" do
          delete :destroy, @params
          response.should be_success
        end
      end
      
      context "for a project previously claimed by the requesting user" do
        it "returns success" do
          delete :destroy, @params
          response.status.should == "200 OK"
        end
        it "disassociates the user from the project" do
          delete :destroy, @params
          @project.reload.user.should be_nil
        end
      end  
      context "for a project previously claimed by a different user" do
        before(:each) do
          @different_user = User.make
          @project.user = @different_user
          @project.save
        end
        it "returns success" do
          delete :destroy, @params
          response.status.should == "401 Unauthorized"
        end
        it "doesn't change the user on the project" do
          delete :destroy, @params
          @project.reload.user.should == @different_user
        end
      end
    end
    context "with an invalid api_key" do
      before(:each) do
        @params.merge!(:api_key => @user.single_access_token + "some junk")
      end
      it "returns 401 unauthorized" do
        delete :destroy, @params
        response.status.should == "401 Unauthorized"
      end
      it "doesn't change the user on the project" do
        delete :destroy, @params
        @project.reload.user.should == @user
      end
    end
  end
end
