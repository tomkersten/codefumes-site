module CoreExtensions
  module ActiveRecord
    module AttributePrecedence
      module ClassMethods
        # A reader for the class-inheritable hash that defines default values for attributes
        def attribute_assignment_ordering
          @attribute_assignment_ordering ||= [:type] # ensure that STI-type is always first
        end

        # Sets one or more default attribute values
        def attribute_assignment_order(*args)
          args.each do |arg|
            if arg.is_a?(Array)
              self.attribute_assignment_ordering += arg
            else
              self.attribute_assignment_ordering << arg
            end
          end
        end
      end

      def self.included(mod)
        mod.extend ClassMethods
        mod.alias_method_chain :attributes=, :precedence
      end

      def attributes_with_precedence=(*args)
        attrs = args.first
        return unless attrs.is_a?(Hash)

        self.class.attribute_assignment_ordering.each do |key|
          next unless attrs.symbolize_keys.key?(key.to_sym)
          send("#{key}=", attrs.delete(key.to_sym) || attrs.delete(key.to_s))
        end
        send("attributes_without_precedence=", *args)
      end
    end
  end
end
