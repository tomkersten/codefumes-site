require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TextHelper do
  describe "inverted_visibility_of" do
    it "returns 'private' if the entity passed in is 'public'" do
      some_entity = mock("Public Object", :public? => true)
      helper.inverted_visibility_of(some_entity).should == 'private'
    end

    it "returns 'public' if the entity passed in is 'private'" do
      some_entity = mock("Private Object", :public? => false)
      helper.inverted_visibility_of(some_entity).should == 'public'
    end
  end

  describe "build_status_class_for" do
    context "when passed in a Project" do
      it "returns '#{Commit::PASSING_BUILD}' if the project passed in is in a '#{Commit::PASSING_BUILD}' state" do
        project = mock_model(Project, :build_status => Commit::PASSING_BUILD)
        helper.build_status_class_for(project).should == Commit::PASSING_BUILD
      end

      it "returns '#{Commit::FAILED_BUILD}' if the project passed in is in a '#{Commit::FAILED_BUILD}' state" do
        project = mock_model(Project, :build_status => Commit::FAILED_BUILD)
        helper.build_status_class_for(project).should == Commit::FAILED_BUILD
      end

      it "returns nil if the project passed in is in a '#{Commit::FAILED_BUILD}' state" do
        project = mock_model(Project, :build_status => nil)
        helper.build_status_class_for(project).should == nil
      end
    end

    context "when passed in a Commit" do
      it "returns '#{Commit::PASSING_BUILD}' if the project passed in is in a '#{Commit::PASSING_BUILD}' state" do
        project = mock_model(Project, :build_status => Commit::PASSING_BUILD)
        helper.build_status_class_for(project).should == Commit::PASSING_BUILD
      end

      it "returns '#{Commit::FAILED_BUILD}' if the project passed in is in a '#{Commit::FAILED_BUILD}' state" do
        project = mock_model(Project, :build_status => Commit::FAILED_BUILD)
        helper.build_status_class_for(project).should == Commit::FAILED_BUILD
      end

      it "returns nil if the project passed in is in a '#{Commit::FAILED_BUILD}' state" do
        project = mock_model(Project, :build_status => nil)
        helper.build_status_class_for(project).should == nil
      end
    end
  end

  describe "commit_classes_for" do
    before(:each) do
      @method_responses = {:merge? => true, :build_status => Commit::FAILED_BUILD}
    end

    it "includes 'merge' if the commit is a merge commit" do
      commit = mock_model(Commit, @method_responses)
      helper.commit_classes_for(commit).should have_text(/merge/)
    end

    it "does not include 'merge' if the commit is not a merge commit" do
      commit = mock_model(Commit, @method_responses.merge(:merge? => false))
      helper.commit_classes_for(commit).should_not have_text(/merge/)
    end

    it "includes the build status of the commit" do
      commit = mock_model(Commit, @method_responses.merge(:merge? => false))
      helper.commit_classes_for(commit).should have_text(/#{helper.build_status_class_for(commit)}/)
    end
  end
end
