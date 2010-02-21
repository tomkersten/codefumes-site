require 'spec_helper'

describe Build do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :start_time => Time.now,
      :end_time => Time.now,
      :state => "value for status"
    }
  end

  it "should create a new instance given valid attributes" do
    Build.create!(@valid_attributes)
  end
end
