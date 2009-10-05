require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Plan do
  describe "the named_scope:" do
    context "'visible'" do
      before(:each) do
        @basic  = Plan.make(:basic)
        @custom = Plan.make(:custom)
      end

      it "returns only plans with a 'visibility' of 'public'" do
        Plan.visible.should == [@basic]
      end
    end
  end
end
