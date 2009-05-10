require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  describe "generate_public_key" do
    it "returns a string" do
      Project.generate_public_key.should be_instance_of(String)
    end

    it "returns a unique string on each call" do
      range = 1..100
      keys = range.map {Project.generate_public_key}
      keys.uniq.size.should == range.count
    end
  end

  describe "validation" do
    def initialize_with(options)
      Project.new(Project.plan(options))
    end

    it "requires a unique public_key" do
      @existing_project = Project.make
      @project2 = initialize_with(:public_key => @existing_project.public_key)
      lambda{@project2.save!}.should raise_error
      @project2.errors.on(:public_key).should_not be_nil
    end
  end

  describe "save hooks" do
    context "on creation" do
      it "generates a public_key if one is not supplied" do
        @project = Project.make(:public_key => nil)
        @project.public_key.should_not be_nil
      end

      it "does not modify the public_key if a valid one is supplied" do
        params = Project.plan
        public_key = params[:public_key]
        @project = Project.create(params)
        @project.public_key.should == public_key
      end

      it "generates a private_key" do
        @project = Project.make(:private_key => nil)
        @project.public_key.should_not be_nil
      end
    end
  end
end
