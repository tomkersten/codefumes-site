require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Build do
  describe "#duration" do
    let(:started_at) {5.minutes.ago}

    context "when a build has completed" do
      let(:build) {Build.make(:successful, :started_at => started_at, :ended_at => started_at + 1.minute)}
      it "returns the number of seconds between the start & end times of the build" do
        build.duration.should == 60
      end
    end

    context "when a build only has a start time" do
      let(:build) {Build.make(:started_at => started_at, :ended_at => nil)}
      it "returns the number of seconds between the start time & the current time" do
        current_time = Time.now
        # confirm result is within a second...so we don't have to stub Time.now
        build.duration.should be_close(current_time - build.started_at, 1)
      end
    end
  end
end
