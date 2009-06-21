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

    it "identifiers must be unique" do
      existing_commit = Commit.make
      commit = Commit.new(Commit.plan(:identifier => existing_commit.identifier))
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

  describe "child_identifiers=" do
    before(:each) do
      @commit = Commit.make
    end

    context "when given a comma-separated list of identifiers" do
      context "and the commit identifiers already exist" do
        before(:each) do
          @associated_commits = 3.times.map {Commit.make}
          @identifiers = @associated_commits.map {|c| c.identifier}.join(", ")
        end

        it "creates 3 new RevisionBridge entries" do
          lambda {
            @commit.child_identifiers = @identifiers
          }.should change(RevisionBridge, :count).by(3)
        end

        it "associates the provided values as children commits" do
          @commit.child_identifiers = @identifiers
          @commit.children.should == @associated_commits
        end

        it "does not creates any new commits" do
          lambda {
            @commit.child_identifiers = @identifiers
          }.should_not change(Commit, :count)
        end
      end

      context "and the identifiers do not exist yet" do
        before(:each) do
          @identifiers = "random_identifier1, random_identifier2, random_identifier3"
        end

        it "associates the provided values as children of the commit" do
          @commit.child_identifiers = @identifiers
          associated_identifiers = @commit.children.map(&:identifier)
          associated_identifiers.should == @identifiers.gsub(/\s/,'').split(",")
        end

        it "creates new commits for the specified identifiers" do
          lambda {
            @commit.child_identifiers = @identifiers
          }.should change(Commit, :count).by(3)
        end
      end

      context "and the commit already has identifiers associated to it" do
        before(:each) do
          existing = 2.times.map {Commit.make}
          new_children = 2.times.map {Commit.make}
          @existing_ids = existing.map(&:identifier).join(', ')
          @new_ids = new_children.map(&:identifier).join(', ')
          @commit.child_identifiers = @existing_ids
        end

        it "associates the new commit identifiers as children" do
          @commit.child_identifiers = @new_ids
          associated_identifiers = @commit.children.map(&:identifier)
          associated_identifiers.should == @new_ids.gsub(/\s/,'').split(",")
        end
      end
    end
  end

  describe "parent_identifiers=" do
    before(:each) do
      @commit = Commit.make
    end

    context "when given a comma-separated list of identifiers" do
      context "and the commit identifiers already exist" do
        before(:each) do
          @associated_commits = 3.times.map {Commit.make}
          @identifiers = @associated_commits.map {|c| c.identifier}.join(", ")
        end

        it "creates 3 new RevisionBridge entries" do
          lambda {
            @commit.parent_identifiers = @identifiers
          }.should change(RevisionBridge, :count).by(3)
        end

        it "associates the provided values as parent commits" do
          @commit.parent_identifiers = @identifiers
          @commit.parents.should == @associated_commits
        end

        it "does not creates any new commits" do
          lambda {
            @commit.parent_identifiers = @identifiers
          }.should_not change(Commit, :count)
        end
      end

      context "and the identifiers do not exist yet" do
        before(:each) do
          @identifiers = %w(random_identifier1 random_identifier2 random_identifier3)
          @identifier_string = @identifiers.join(', ')
        end

        it "associates the provided values as children of the commit" do
          @commit.parent_identifiers = @identifier_string
          associated_identifiers = @commit.parents.map(&:identifier)
          associated_identifiers.should == @identifiers
        end

        it "creates new commits for the specified identifiers" do
          lambda {
            @commit.parent_identifiers = @identifier_string
          }.should change(Commit, :count).by(3)
        end
      end

      context "and the commit already has identifiers associated to it" do
        before(:each) do
          existing = 2.times.map {Commit.make}
          new_children = 2.times.map {Commit.make}
          @existing_ids = existing.map(&:identifier).join(', ')
          @new_ids = new_children.map(&:identifier).join(', ')
          @commit.parent_identifiers = @existing_ids
        end

        it "associates the new commit identifiers as children" do
          @commit.parent_identifiers = @new_ids
          associated_identifiers = @commit.parents.map(&:identifier)
          associated_identifiers.should == @new_ids.gsub(/\s/,'').split(",")
        end
      end
    end
  end

  describe "associations" do
    it "is associated to many bridges_as_parent" do
      revision_bridge = RevisionBridge.make
      commit = revision_bridge.parent
      commit.bridges_as_parent.should include(revision_bridge)
    end

    it "is associated to many bridges_as_child" do
      revision_bridge = RevisionBridge.make
      commit = revision_bridge.child
      commit.bridges_as_child.should include(revision_bridge)
    end

    it "destroys associated bridges_as_parent records on deletion" do
      revision_bridge = RevisionBridge.make
      commit = revision_bridge.parent
      commit.destroy
      RevisionBridge.exists?(revision_bridge.id).should == false
    end

    it "destroys associated bridges_as_child records on deletion" do
      revision_bridge = RevisionBridge.make
      commit = revision_bridge.child
      commit.destroy
      RevisionBridge.exists?(revision_bridge.id).should == false
    end

    it "is associated to many child commits (children)" do
      parent_commit = Commit.make
      child_commits = 3.times.map {Commit.make}
      parent_commit.children << child_commits
      parent_commit.reload
      parent_commit.children.should == child_commits
    end

    it "is associated to many parents" do
      child_commit = Commit.make
      parent_commits = 3.times.map {Commit.make}
      child_commit.parents << parent_commits
      child_commit.reload
      child_commit.parents.should == parent_commits
    end
  end
end
