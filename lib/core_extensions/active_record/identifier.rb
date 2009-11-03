module CoreExtensions
  module ActiveRecord
    # gives you a really robust scope, and [] accessor, based on a given field
    # e.g. User.class_eval{identifier :permalink} ; User.identifiable_by('homey').first, or User['homey']
    module Identifier
      def self.included(mod)
        mod.extend ClassMethods
      end

      module ClassMethods
        def identifier(field)
          class_eval do
            named_scope :identifiable_by, proc {|permalink_or_id|
              permalink_or_id = permalink_or_id.target if permalink_or_id.respond_to?(:target)
              permalink_or_id = case permalink_or_id
              when /,/ : permalink_or_id.split(/,/).map(&:to_s+:strip)
              when Array
                permalink_or_id.map do |object|
                  (object.respond_to?(:to_param) ? object.to_param : object.to_s).strip
                end
              when Fixnum, String : permalink_or_id.to_s.strip
              else # possibly a permalinkable object
                permalink_or_id.permalink unless permalink_or_id.blank?
              end

              if permalink_or_id.blank?
                {:conditions => "1=0"} # only way to abort with mysql
              elsif permalink_or_id.is_a?(Fixnum) or permalink_or_id =~ /^\d+$/
                {:conditions => {:id => permalink_or_id.to_i}}
              else
                {:conditions => {field => permalink_or_id}}
              end
            }

            class << self
              define_method :[] do |slug|
                identifiable_by(slug).first
              end
            end
          end
        end
      end
    end
  end
end
