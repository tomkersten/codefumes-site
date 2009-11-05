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
end
