require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RevisionBridge do
  describe "associations" do
    before(:each) do
      @revision_bridge = RevisionBridge.make
    end

    context "parent" do
      it "returns an instance of a Commit object" do
        @revision_bridge.parent.should be_instance_of(Commit)
      end
    end

    context "child" do
      it "returns an instance of a Commit object" do
        @revision_bridge.child.should be_instance_of(Commit)
      end
    end
  end

  describe "validations" do
    it "does not allow duplicate parent_id-child_id entries" do
      @revision_bridge = RevisionBridge.make
      custom_params = {:parent_id => @revision_bridge.parent_id, :child_id  => @revision_bridge.child_id}
      params = RevisionBridge.plan(custom_params)
      @new_revb = RevisionBridge.new(params)
      @new_revb.should_not be_valid
    end

    it "does not allow entries to have the same value for parent_id & child_id" do
      commit = Commit.make
      params = RevisionBridge.plan(:parent_id => commit.id, :child_id => commit.id)
      @revision_bridge = RevisionBridge.new(params)
      @revision_bridge.should_not be_valid
    end
  end
end
