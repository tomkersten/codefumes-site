require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Commit do
  describe "revisions" do
    before(:each) do
      @commit = Commit.make
      @revision = Revision.make(:commit_id => @commit.id)
    end

    it "is associated with revisions" do
      lambda {@commit.revisions << @revision}.should_not raise_error
    end

    it "destroys associated revisions when destroyed" do
      Revision.find_by_id(@revision.id).should == @revision
      @commit.destroy
      Revision.find_by_id(@revision.id).should be_nil
    end
  end

  describe "projects" do
    before(:each) do
      @project = Project.make
      @commit = Commit.make
      @revision = Revision.make(:project_id => @project.id, :commit_id => @commit.id)
    end

    it "is associated with many projects" do
      lambda {@commit.projects << @project}.should_not raise_error
    end

    it "does not destroy associated commits when destroyed" do
      Project.find_by_id(@project.id).should == @project
      @commit.destroy
      Project.find_by_id(@project.id).should == @project
    end
  end
end
