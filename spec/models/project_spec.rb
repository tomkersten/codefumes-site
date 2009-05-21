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

  describe "to_param" do
    it "returns the public key instead of the id" do
      project = Project.make
      project.to_param.should == project.public_key
    end
  end

  describe "to_s" do
    context "when the project name has been set" do
      before(:each) do
        @a_name = "Some name"
        @project = Project.make(:name => @a_name)
      end

      it "returns the project name" do
        @project.to_s.should == @a_name
      end
    end

    context "when the project name has not been set" do
      before(:each) do
        @project = Project.make(:name => nil)
      end

      it "returns the project's public key" do
        @project.to_s.should == @project.public_key
      end
    end
  end

  describe "attributes protected from mass assignment include:" do
    before(:each) do
      @project = Project.make
    end

    it "private_key" do
      original_private_key = @project.private_key
      new_private_key = @project.private_key + "_different_value"
      @project.update_attributes(:private_key => new_private_key)
      @project.reload
      @project.private_key.should == original_private_key
    end
  end
end
