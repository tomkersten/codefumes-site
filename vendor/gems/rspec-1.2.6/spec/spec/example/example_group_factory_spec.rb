require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Spec
  module Example
    describe ExampleGroupFactory do
      describe "#get" do
        attr_reader :example_group
        before(:each) do
          @example_group_class = Class.new(ExampleGroupDouble)
          ExampleGroupFactory.register(:registered_type, @example_group_class)
        end

        after(:each) do
          ExampleGroupFactory.reset
        end

        it "should return the default ExampleGroup type for nil" do
          ExampleGroupFactory[nil].should == ExampleGroup
        end

        it "should return the default ExampleGroup for an unregistered non-nil value" do
          ExampleGroupFactory[:does_not_exist].should == ExampleGroup
        end

        it "should return custom type if registered" do
          ExampleGroupFactory[:registered_type].should == @example_group_class
        end

        it "should get the custom type after setting the default" do
          @alternate_example_group_class = Class.new(ExampleGroupDouble)
          ExampleGroupFactory.default(@alternate_example_group_class)
          ExampleGroupFactory[:registered_type].should == @example_group_class
        end
      end

      describe "#create_example_group" do
        attr_reader :parent_example_group
        before do
          @parent_example_group = Class.new(ExampleGroupDouble) do
            def initialize(*args, &block)
              ;
            end
          end
        end

        it "should create a uniquely named class" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("example_group") {}
          example_group.name.should =~ /Spec::Example::ExampleGroup::Subclass_\d+/
        end

        it "should create a Spec::Example::Example subclass by default" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("example_group") {}
          example_group.superclass.should == Spec::Example::ExampleGroup
        end

        it "should raise when no description is given" do
          lambda {
            Spec::Example::ExampleGroupFactory.create_example_group do; end
          }.should raise_error(ArgumentError)
        end

        it "should raise when no block is given" do
          lambda { Spec::Example::ExampleGroupFactory.create_example_group "foo" }.should raise_error(ArgumentError)
        end

        it "should run registered ExampleGroups" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group "The ExampleGroup" do end
          Spec::Runner.options.example_groups.should include(example_group)
        end

        it "should not run unregistered ExampleGroups" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group "The ExampleGroup" do Spec::Runner.options.remove_example_group self; end
          Spec::Runner.options.example_groups.should_not include(example_group)
        end

        describe "with :type => :default" do
          it "should create a Spec::Example::ExampleGroup" do
            example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group", :type => :default
            ) {}
            example_group.superclass.should == Spec::Example::ExampleGroup
          end
        end

        describe "with :type => :something_other_than_default" do
          it "should create the specified type" do
            Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
            non_default_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
              "example_group", :type => :something_other_than_default
            ) {}
            non_default_example_group.superclass.should == parent_example_group
          end
        end

        it "should create a type indicated by :location" do
          Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group", :location => "./spec/something_other_than_default/some_spec.rb"
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        it "should create a type indicated by :location (with location generated by caller on windows)" do
          Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group",
            :location => "./spec\\something_other_than_default\\some_spec.rb"
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        it "should create a type indicated by location for a path-like key" do
          Spec::Example::ExampleGroupFactory.register('path/to/custom/', parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group", :location => "./spec/path/to/custom/some_spec.rb"
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        it "should use the longest key that matches when creating a type indicated by location" do
          longer = Class.new parent_example_group
          Spec::Example::ExampleGroupFactory.register(:longer, longer)
          long = Class.new parent_example_group
          Spec::Example::ExampleGroupFactory.register(:long, long)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group", :location => "./spec/longer/some_spec.rb"
          ) {}
          custom_example_group.superclass.should == longer
        end

        describe "with :shared => true" do
          def shared_example_group
            @shared_example_group ||= Spec::Example::ExampleGroupFactory.create_example_group(
              "name", :location => '/blah/spec/models/blah.rb', :type => :controller, :shared => true
            ) {}
          end

          it "should create and register a Spec::Example::SharedExampleGroup" do
            shared_example_group.should be_an_instance_of(Spec::Example::SharedExampleGroup)
            SharedExampleGroup.should include(shared_example_group)
          end
        end

        it "should favor the :type over the :location" do
          Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "name", :location => '/blah/spec/models/blah.rb', :type => :something_other_than_default
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        it "should register ExampleGroup by default" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("The ExampleGroup") do
          end
          Spec::Runner.options.example_groups.should include(example_group)
        end

        it "should enable unregistering of ExampleGroups" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("The ExampleGroup") do
            Spec::Runner.options.remove_example_group self
          end
          Spec::Runner.options.example_groups.should_not include(example_group)
        end

        after(:each) do
          Spec::Example::ExampleGroupFactory.reset
        end
      end

      describe "#create_shared_example_group" do
        it "registers a new shared example group" do
          shared_example_group = Spec::Example::ExampleGroupFactory.create_shared_example_group("something shared") {}
          shared_example_group.should be_an_instance_of(Spec::Example::SharedExampleGroup)
          SharedExampleGroup.should include(shared_example_group)
        end
      end

    end
  end
end
