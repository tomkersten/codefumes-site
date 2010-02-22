require 'spec_helper'

describe Build do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :started_at => Time.now,
      :ended_at => Time.now,
      :state => "value for status"
    }
  end

  it "should create a new instance given valid attributes" do
    Build.create!(@valid_attributes)
  end
end
