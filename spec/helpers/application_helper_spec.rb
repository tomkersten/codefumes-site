require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe "ie?" do
    it "returns true if request headers define IE user agent"
    it "returns false if request headers do not define IE user agent"
  end
end
