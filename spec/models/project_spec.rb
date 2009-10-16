require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  describe "generate_public_key" do
    it "returns a string" do
      Project.generate_public_key.should be_instance_of(String)
    end

    it "returns a unique string on each call" do
      range = 1..100
      keys = range.map {Project.generate_public_key}
      keys.uniq.size.should == range.count
    end
  end

  describe "validation" do
    def initialize_with(options)
      Project.new(Project.plan(options))
    end

    it "requires a unique public_key" do
      @existing_project = Project.make
      @project2 = initialize_with(:public_key => @existing_project.public_key)
      lambda{@project2.save!}.should raise_error
      @project2.errors.on(:public_key).should_not be_nil
    end
  end

  describe "save hooks" do
    context "on creation" do
      it "generates a public_key if one is not supplied" do
        @project = Project.make(:public_key => nil)
        @project.public_key.should_not be_nil
      end

      it "does not modify the public_key if a valid one is supplied" do
        params = Project.plan
        public_key = params[:public_key]
        @project = Project.create(params)
        @project.public_key.should == public_key
      end

      it "generates a private_key" do
        @project = Project.make(:private_key => nil)
        @project.public_key.should_not be_nil
      end
    end

    context "when saving a private project" do
      context "when privatized_at is not set" do
        it "sets it" do
          project = Project.make(:private, :privatized_at => nil)
          project.privatized_at.should_not be_nil
        end
      end

      context "when privatized_at is" do
        it "doesn't modify the value" do
          cached_time = 15.minutes.ago
          project = Project.make(:private, :privatized_at => cached_time)
          project.privatized_at.to_s.should == cached_time.to_s
        end
      end
    end
  end

  describe "to_param" do
    it "returns the public key instead of the id" do
      project = Project.make
      project.to_param.should == project.public_key
    end
  end

  describe "to_s" do
    context "when the project name has been set" do
      before(:each) do
        @a_name = "Some name"
        @project = Project.make(:name => @a_name)
      end

      it "returns the project name" do
        @project.to_s.should == @a_name
      end
    end

    context "when the project name has not been set" do
      before(:each) do
        @project = Project.make(:name => nil)
      end

      it "returns the project's public key" do
        @project.to_s.should == @project.public_key
      end
    end
  end
  
  describe "visibility" do
    it "defaults to public" do
      Project.new.visibility.should == Project::PUBLIC
    end
  end

  describe "attributes protected from mass assignment include:" do
    before(:each) do
      @project = Project.make
    end

    [:private_key].each do |attribute_name|
      it "attribute.to_s" do
        original_attribute_value = @project.send(attribute_name)
        new_attribute_value = original_attribute_value + "_different_value"
        @project.update_attributes(attribute_name => new_attribute_value)
        @project.reload
        @project.send(attribute_name).should == original_attribute_value
      end
    end
    
    it "visibility" do
      @project.visibility.should == Project::PUBLIC
      @project.update_attributes(:visibility => Project::PRIVATE)
      @project.reload
      @project.visibility.should == Project::PUBLIC
    end
    
  end

  describe "commits" do
    before(:each) do
      @project = Project.make
      @commit = Commit.make
    end

    it "is associated with many commits" do
      lambda {@project.commits << @commit}.should_not raise_error
    end

    it "does not destroy associated commits when destroyed" do
      Commit.find_by_id(@commit.id).should == @commit
      @project.destroy
      Commit.find_by_id(@commit.id).should == @commit
    end
  end

  describe "payloads" do
    before(:each) do
      @project = Project.make
      @payload = Payload.make(:project_id => @project.id)
    end

    it "is associated with many payloads" do
      lambda {@project.payloads << @payload}.should_not raise_error
    end

    it "destroys associated payloads when destroyed" do
      finding_payload = lambda {Payload.find(@payload.id)}
      finding_payload.should_not raise_error
      @project.destroy
      finding_payload.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "commit_head" do
    before(:each) do
      @project = Project.make
      @commits = 3.times.map {Commit.make(:committed_at => 2.days.ago)}
      @commits << Commit.make
      # Build out the commit hierarchy
      @commits.each_with_index do |commit, index|
        identifier = @commits[index+1] && @commits[index+1].identifier
        commit.child_identifiers = identifier || ""
      end
    end

    context "when the project has commits associated with it" do
      before(:each) do
        @project.commits << @commits
      end

      it "returns the most recent commit associated to the project" do
        @project.commit_head.should == @commits.last
      end
    end

    context "when the project does not have any commits associated with it" do
      before(:each) do
        @project.commits.destroy_all
      end

      it "returns nil" do
        @project.commit_head.should == nil
      end
    end

    context "Project 1 has commits [A], Project 2 has commits [A,B]" do
      before(:each) do
        @commit_1a = Commit.make
        @commit_2a = Commit.make
        @commit_2b = Commit.make(:parent_identifiers => @commit_2a.identifier)
        @commit_2b.parents.first.should == @commit_2a
        @project_1 = Project.make(:public_key => "Project 1", :commits => [@commit_1a])
        @project_2 = Project.make(:public_key => "Project 2", :commits => [@commit_2a, @commit_2b])
      end

      it "calling commit_head on Project 1, returns commit A's identifier'" do
        @project_1.commit_head.should == @commit_1a
      end

      it "calling commit_head on Project 2, returns commit B's identifier'" do
        @project_2.commit_head.should == @commit_2b
      end
    end
  end

  describe "recent_commits" do
    before(:each) do
      @project = Project.make
    end

    context "when a project has no commits" do
      before(:each) do
        @project.commits.destroy_all
      end

      it "returns an empty list" do
        @project.recent_commits.should be_empty
      end
    end

    context "when a project has multiple commits" do
      before(:each) do
        @commits = 5.times.map {Commit.make}
        @commits.each_with_index do |commit, index|
          identifier = @commits[index+1] && @commits[index+1].identifier
          commit.child_identifiers = identifier || ""
        end
        @project.commits << @commits
      end

      it "returns a list of the specified size with commit objects" do
        @project.recent_commits(3).size.should == 3
      end

      it "the first element in the array is the 'commit_head'" do
        @project.recent_commits(3).first.should == @project.commit_head
      end

      it "the last element in the array is the third commit from most recent" do
        @project.recent_commits(3).last.should == @commits[2]
      end
    end
  end

  describe "covered_by_plan?" do
    context "on public projects" do
      it "returns true" do
        Project.make(:public).should be_covered_by_plan
      end
    end

    context "on private projects" do
      before(:each) do
        @project = Project.make(:privatized_at => 1.week.ago)
        @user = Subscription.make(:doras).user
        @user.claim(@project, "private")
      end

      context "when the account has two projects, both privatized over a week ago, and a Basic subscription" do
        before(:each) do
          @project.update_attribute(:privatized_at, 9.days.ago.utc)
          @second_project = Project.make
          @user.claim(@second_project, "private")
          @second_project.update_attribute(:privatized_at, 8.days.ago.utc)
        end

        it "returns false for the second (uncovered) project" do
          @second_project.should_not be_covered_by_plan
        end

        it "returns true for the first (covered) project" do
          @project.should be_covered_by_plan
        end
      end
    end
  end
end
