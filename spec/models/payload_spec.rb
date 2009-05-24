require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Payload do

  it "serializes the value of 'content' to/from YAML" do
    payload_params = {"commits" => [1,2,3], "after" => 'sha1_after', "before" => 'sha1_before'}
    payload = Payload.make(:content => payload_params)
    payload.content.should == payload_params
  end

  describe "associations" do
    context "project" do
      before(:each) do
        @project = Project.make
        @payload = Payload.new(Payload.plan(:project_id => nil))
      end

      it 'can be associated to a project' do
        @payload.project = @project
        @payload.should be_valid
      end

      it "knows the project it was associated with" do
        @payload.project = @project
        @payload.save.should be_true
        @payload.project.should == @project
      end
    end
  end
end
