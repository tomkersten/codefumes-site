require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Community::AttributesController do
  describe "a get to show" do
    before(:each) do
      @project = Project.make
      @attribute = 'temperature'
    end

    it "assigns the requested attribute for the view template" do
      get :show, :attribute => @attribute, :public_key => @project.to_param
      assigns[:attribute].should == @attribute
      assigns[:project].should == @project
    end
  end
end
