require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::ClaimController do
  
  before(:each) do
    @project = Project.make
    @user = User.make
    @params = {:project_id => @project.public_key, :visibility => Project::PRIVATE}
    setup_basic_auth(@project.public_key, @project.private_key)
  end
  
  describe "a PUT to update" do
    
    context "with invalid project credentials" do
      before(:each) do
        setup_basic_auth("some", "garbage")
        put :update, @params
      end
      it "returns 401 unauthorized" do
        response.status.should == "401 Unauthorized"
      end
      it "doesn't change the user on the project" do
        @project.reload.user.should_not == @user
      end
      it "doesn't change the visibility on the project" do
        @project.reload.visibility.should == Project::PUBLIC
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
          before(:each) do 
            put :update, @params
          end
          it "sets the user on the project" do
            @project.reload.user.should == @user
          end  
          it "sets the visibility on the project" do
            @project.reload.visibility.should == Project::PRIVATE
          end
          it "returns a response of OK" do
            response.status.should == "200 OK"
          end
        end
        
        context "for a project owned by the current_user" do
          before(:each) do
            @project.user = @user
            @project.save!
            put :update, @params
          end
          it "leaves the current_user as the owner of the project" do
            @project.reload.user.should == @user
          end
          it "returns a response of OK" do
            response.status.should == "200 OK"
          end
          it "sets the visibility on the project" do
            @project.reload.visibility.should == Project::PRIVATE
          end
        end
        
        context "for a previously claimed project" do
          before(:each) do
            @project.user = User.make
            @project.save!
            put :update, @params
          end
          it "returns 401 unauthorized" do
            response.status.should == "401 Unauthorized"
          end
          it "doesn't change the user on the project" do
            @project.reload.user.should_not == @user
          end
          it "doesn't change the visibility on the project" do
            @project.reload.visibility.should == Project::PUBLIC
          end
        end  
      end
      context "with an invalid api_key" do
        before(:each) do
          @params.merge!(:api_key => @user.single_access_token + "some junk")
          put :update, @params 
        end
        it "returns 401 unauthorized" do
          response.status.should == "401 Unauthorized"
        end
        it "doesn't change the user on the project" do
          @project.reload.user.should_not == @user
        end
        it "doesn't change the visibility on the project" do
          @project.reload.visibility.should == Project::PUBLIC
        end
      end
    

    end
    
    
  end

  describe "DELETE to 'destroy'" do
    before(:each) do
      @project = Project.make(:private)
      @user = User.make
      @params = {:project_id => @project.public_key, :visibility => Project::PRIVATE}
      setup_basic_auth(@project.public_key, @project.private_key)
      @project.user = @user
      @project.save!
    end
    context "with invalid project credentials" do
      before(:each) do
        setup_basic_auth("some", "garbage")
        delete :destroy, @params
      end
      it "returns 401 unauthorized" do
        response.status.should == "401 Unauthorized"
      end
      it "doesn't change the user on the project" do
        @project.reload.user.should == @user
      end
      it "doesn't change the visibility on the project" do
        @project.reload.visibility.should == Project::PRIVATE
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
        it "returns a response of OK" do
          delete :destroy, @params
          response.should be_success
        end
      end
      
      context "for a project previously claimed by the requesting user" do
        before(:each) do
          delete :destroy, @params
        end
        it "returns success" do
          response.status.should == "200 OK"
        end
        it "disassociates the user from the project" do
          @project.reload.user.should be_nil
        end
        it "sets the project visibility to public" do
          @project.reload.visibility.should == Project::PUBLIC
        end
      end  
      context "for a project previously claimed by a different user" do
        before(:each) do
          @different_user = User.make
          @project.user = @different_user
          @project.save
          delete :destroy, @params
        end
        it "returns success" do
          response.status.should == "401 Unauthorized"
        end
        it "doesn't change the user on the project" do
          @project.reload.user.should == @different_user
        end
        it "doesn't change the visibility on the project" do
          @project.reload.visibility.should == Project::PRIVATE
        end
      end
    end
    context "with an invalid api_key" do
      before(:each) do
        @params.merge!(:api_key => @user.single_access_token + "some junk")
        delete :destroy, @params
      end
      it "returns 401 unauthorized" do
        response.status.should == "401 Unauthorized"
      end
      it "doesn't change the user on the project" do
        @project.reload.user.should == @user
      end
      it "doesn't change the visibility on the project" do
        @project.reload.visibility.should == Project::PRIVATE
      end
    end
  end
end
