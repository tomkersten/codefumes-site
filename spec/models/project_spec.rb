require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  context "generate_key" do
    it "returns a string" do
      Project.generate_key.should be_instance_of(String)
    end

    it "returns a unique string on each call" do
      range = 1..100
      keys = range.map {Project.generate_key}
      keys.uniq.size.should == range.count
    end
  end
end
