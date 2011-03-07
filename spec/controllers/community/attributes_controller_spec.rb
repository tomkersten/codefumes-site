require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Community::AttributesController do
  describe "a get to show" do
    let(:project) {Project.make}
    let(:attribute) {'temperature'}

    def do_get
      get :show, :attribute => attribute, :public_key => project.to_param
    end

    it "assigns the requested attribute for the view template" do
      do_get
      assigns[:attribute].should == attribute
    end

    it "assigns the requested project for the view template" do
      do_get
      assigns[:project].should == project
    end

    it "assigns the requested attribute for the view template" do
      commits = [Commit.make(:project => project)]
      do_get
      assigns[:commits].should == commits
    end
  end
end
