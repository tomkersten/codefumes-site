require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Revision do
  describe "associations" do
    before(:each) do
      @revision = Revision.make
    end

    it "is associated with a Project" do
      @revision.project.should be_instance_of(Project)
    end

    it "is associated with a Commit" do
      @revision.commit.should be_instance_of(Commit)
    end
  end

  describe "validations" do
    it "does not allow duplicate project_id-commit_id entries" do
      existing_revision = Revision.make
      custom_params = {:project_id => existing_revision.project_id, :commit_id  => existing_revision.commit_id}
      new_revision = Revision.new(Revision.plan(custom_params))
      new_revision.should_not be_valid
    end

    it "requires a commit_id" do
      revision = Revision.new(Revision.plan(:commit_id => nil))
      lambda {
        revision.should_not be_valid
        revision.errors.on(:commit_id).should_not be_nil
      }.should_not change(Revision, :count)
    end

    it "requires a project_id" do
      revision = Revision.new(Revision.plan(:project_id => nil))
      lambda {
        revision.should_not be_valid
        revision.errors.on(:project_id).should_not be_nil
      }.should_not change(Revision, :count)
    end
  end
end
