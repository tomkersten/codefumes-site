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

  describe "validations" do
    it "requires an identifier" do
      commit = Commit.new(Commit.plan(:identifier => nil))
      commit.should_not be_valid
      commit.errors.on(:identifier).should_not == nil
    end
  end

  describe "to_param" do
    it "returns the commit identifier instead of the id" do
      commit = Commit.make
      commit.to_param.should == commit.identifier
    end
  end

  context "helper methods" do
    before(:each) do
      @commit = Commit.make
    end

    describe "committer" do
      it "returns the name & email of the comitter as a single string" do
        @commit.committer.should have_text(/#{@commit.committer_name}/)
        @commit.committer.should have_text(/#{@commit.committer_email}/)
      end
    end

    describe "author" do
      it "returns the name & email of the author as a single string" do
        @commit.author.should have_text(/#{@commit.author_name}/)
        @commit.author.should have_text(/#{@commit.author_email}/)
      end
    end
  end
end
