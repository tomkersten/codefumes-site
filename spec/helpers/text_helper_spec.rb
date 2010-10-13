require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TextHelper do
  describe "#inverted_visibility_of" do
    it "returns 'private' if the entity passed in is 'public'" do
      some_entity = mock("Public Object", :public? => true)
      helper.inverted_visibility_of(some_entity).should == 'private'
    end

    it "returns 'public' if the entity passed in is 'private'" do
      some_entity = mock("Private Object", :public? => false)
      helper.inverted_visibility_of(some_entity).should == 'public'
    end
  end

  describe "#build_status_class_for" do
    context "when passed in a Project" do
      it "returns '#{Build::SUCCESSFUL}' if the project passed in is in a '#{Build::SUCCESSFUL}' state" do
        project = mock_model(Project, :build_status => Build::SUCCESSFUL)
        helper.build_status_class_for(project).should == Build::SUCCESSFUL
      end

      it "returns '#{Build::FAILED}' if the project passed in is in a '#{Build::FAILED}' state" do
        project = mock_model(Project, :build_status => Build::FAILED)
        helper.build_status_class_for(project).should == Build::FAILED
      end

      it "returns nil if the project passed in is in a '#{Build::FAILED}' state" do
        project = mock_model(Project, :build_status => nil)
        helper.build_status_class_for(project).should == nil
      end
    end

    context "when passed in a Commit" do
      it "returns '#{Build::SUCCESSFUL}' if the project passed in is in a '#{Build::SUCCESSFUL}' state" do
        project = mock_model(Project, :build_status => Build::SUCCESSFUL)
        helper.build_status_class_for(project).should == Build::SUCCESSFUL
      end

      it "returns '#{Build::FAILED}' if the project passed in is in a '#{Build::FAILED}' state" do
        project = mock_model(Project, :build_status => Build::FAILED)
        helper.build_status_class_for(project).should == Build::FAILED
      end

      it "returns nil if the project passed in is in a '#{Build::FAILED}' state" do
        project = mock_model(Project, :build_status => nil)
        helper.build_status_class_for(project).should == nil
      end
    end

    context "when passed in a Build" do
      it "returns '#{Build::SUCCESSFUL}' if the build passed in is in a '#{Build::SUCCESSFUL}' state" do
        build = mock_model(Build, :state => Build::SUCCESSFUL)
        helper.build_status_class_for(build).should == Build::SUCCESSFUL
      end

      it "returns '#{Build::FAILED}' if the build passed in is in a '#{Build::FAILED}' state" do
        build = mock_model(Build, :state => Build::FAILED)
        helper.build_status_class_for(build).should == Build::FAILED
      end
    end
  end

  describe "#commit_classes_for" do
    let(:method_responses) {{:merge? => true, :build_status => Build::FAILED}}

    it "includes 'merge' if the commit is a merge commit" do
      commit = mock_model(Commit, method_responses)
      helper.commit_classes_for(commit).should have_text(/merge/)
    end

    it "does not include 'merge' if the commit is not a merge commit" do
      commit = mock_model(Commit, method_responses.merge(:merge? => false))
      helper.commit_classes_for(commit).should_not have_text(/merge/)
    end

    it "returns an empty string if nil is passed in" do
      helper.commit_classes_for(nil).should == ''
    end
  end

  # This is messy as shit, but not sure how else to do it w/ a helper method
  # which uses haml_tag &/or haml_concat
  # Found here: http://bit.ly/c5YGm4
  describe '#build_duration_text_for' do
    before(:each) do
      helper.extend Haml
      helper.extend Haml::Helpers
      helper.send :init_haml_helpers
    end

    it "returns the average time of all builds when passed in a commit" do
      commit = mock_model(Commit, {:average_build_duration => 93})
      helper.capture_haml {
        helper.build_duration_text_for(commit)
      }.should match(/1min\s33secs/)
    end

    it "returns the build time of the build when passed in a build" do
      build = Build.make_unsaved(:failed)
      helper.capture_haml {
        helper.build_duration_text_for(build)
      }.should match(/\dmin\s\d+secs/)
    end

    it "wraps the output in a span with a class of 'duration'" do
      commit = mock_model(Commit, {:average_build_duration => 93})
      helper.capture_haml {
        helper.build_duration_text_for(commit)
      }.should match(/<span.*class='.*duration.*'/)
    end

    context "when the commit has builds associated with it" do
      it "returns the average build duration split into 'Xm XXsecs' format" do
        commit = mock_model(Commit, {:average_build_duration => 93})
        helper.capture_haml {
          helper.build_duration_text_for(commit)
        }.should match(/1min\s33secs/)
      end
    end

    context "when the commit has builds associated with it" do
      it "returns the average build duration split into 'Xm XXsecs' format" do
        pending "I wasn't scrazy about how this affected the view...need to think about it"
        commit = mock_model(Commit, {:average_build_duration => 0})
        helper.capture_haml {
          helper.build_duration_text_for(commit)
        }.should match(/using ci/)
      end
    end
  end
end
