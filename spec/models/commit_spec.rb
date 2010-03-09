require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Commit do
  describe "projects" do
    before(:each) do
      @project = Project.make
      @commit = Commit.make
    end

    it "is associated with a project" do
      lambda {@commit.project = @project}.should_not raise_error
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

    it "identifiers must be unique within a project" do
      existing_commit = Commit.make(:project_id => 1)
      commit = Commit.new(Commit.plan(:identifier => existing_commit.identifier, :project_id => existing_commit.project_id))
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

  describe "merge?" do
    it "returns true when a commit has multiple parents" do
      commit = Commit.make
      parents = [Commit.make, Commit.make]
      commit.parents << parents
      commit.merge?.should == true
    end

    it "returns false when a commit has a single parent" do
      commit = Commit.make
      parent = Commit.make
      commit.parents << parent
      commit.merge?.should == false
    end
  end

  describe "parent_identifiers" do
    it "returns a list of the parent identifiers of a commit" do
      commit = Commit.make
      parents = [Commit.make, Commit.make]
      commit.parents << parents
      commit.parent_identifiers.should == parents.map(&:identifier)
    end

    it "returns an empty list when no parents exist" do
      Commit.make.parent_identifiers.should == []
    end

    context "when passed in a parameter of ':short'" do
      it "returns a list of the parent identifiers of a commit" do
        commit = Commit.make
        parents = [Commit.make, Commit.make]
        commit.parents << parents
        shortended_identifiers = parents.map(&:short_identifier)
        commit.parent_identifiers(:short).should == shortended_identifiers
      end
    end
  end

  describe "short_identifier" do
    it "returns the first 9 characters of the commit identifier" do
      commit = Commit.make
      commit.short_identifier.should == commit.identifier[0...8]
    end
  end

  describe "normalizing attribute lists" do
    before(:each) do
      @params = {:identifier => "1234", :line_additions => "10"}
    end

    it "does not modify the original object passed in" do
      params = @params.dup
      Commit.normalize_params(@params)
      params.should == @params
    end

    it "allows 'parent_identifiers' to be set" do
      parent_ids = "abc, 123"
      @params.merge!(:parent_identifiers => parent_ids)
      results = Commit.normalize_params(@params)
      results.should include(:parent_identifiers)
      results[:parent_identifiers].should == parent_ids
    end

    context "when passing in a standard keypairs only" do
      it "does not return a 'custom_attributes' key" do
        Commit.normalize_params(@params).should_not include(:custom_attributes)
      end
    end

    context "when passing in a custom key in the root level of the params argument" do
      before(:each) do
        @custom_keypair = {:custom_field => "random_value"}
        @params.merge!(@custom_keypair)
        @results = Commit.normalize_params(@params)
      end

      it "passes the valid/standard parameters straight through" do
        @results[:identifier].should == "1234"
        @results[:line_additions].should == "10"
        @results.should have(2).keys
      end

      it "silently ignores/removes non-supported attributes" do
        @results[:custom_attributes].should be_nil
        @results[:custom_field].should be_nil
      end
    end
  end

  describe "setting custom attributes" do
    before(:each) do
      @params = {:identifier => "1234", :line_additions => "10"}
    end

    context "when not nested under the ':custom_attributes' key" do
      before(:each) do
        @params.merge!(:custom_attributes => {:rcov => "100"})
      end

      it "retains the standard commit attribute values" do
        commit = Commit.make(Commit.normalize_params(@params))
        commit.identifier.should == @params[:identifier]
        commit.line_additions.should == @params[:line_additions].to_i
      end

      it "creates a new commit attribute with the key-value pair supplied" do
        commit = Commit.make(Commit.normalize_params(@params))
        commit.custom_attributes[:rcov].should_not be_nil
        commit.custom_attributes[:rcov].value.should == "100"
      end
    end
  end

  describe "build_status" do
    before(:each) do
      @commit = Commit.make
    end

    it "returns the value of Commit::NOBUILDS when no builds are associated with the commit" do
      @commit.build_status.should  == Commit::NOBUILDS
    end

    it "returns the value of Commit::PASSING_BUILD when only passing builds are associated with the commit" do
      @commit.builds.create!(Build.plan(:success))
      @commit.build_status.should  == Commit::PASSING_BUILD
    end

    it "returns the value of Commit::FAILED_BUILD when a build in a 'failure' state is associated with the commit" do
      @commit.builds.create!(Build.plan(:success))
      @commit.builds.create!(Build.plan(:failure))
      @commit.build_status.should == Commit::FAILED_BUILD
    end

    it "returns the value of Commit::RUNNING when there is a build in a 'running' state associated with the commit" do
      @commit.builds.create!(Build.plan(:success))
      @commit.builds.create!(Build.plan(:running))
      @commit.builds.create!(Build.plan(:failure))
      @commit.build_status.should == Commit::RUNNING_BUILD
    end
  end
end
