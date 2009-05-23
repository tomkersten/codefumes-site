class Revision < ActiveRecord::Base
  validates_presence_of :commit_id
  validates_presence_of :project_id
  belongs_to :project
  belongs_to :commit
end
