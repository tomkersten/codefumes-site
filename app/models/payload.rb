class Payload < ActiveRecord::Base
  belongs_to :project
  serialize :content
end
