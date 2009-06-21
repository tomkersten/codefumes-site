class Revision < ActiveRecord::Base
  validates_uniqueness_of :commit_id, :scope => :project_id
  validates_uniqueness_of :project_id, :scope => :commit_id
  validates_presence_of :commit_id
  validates_presence_of :project_id
  belongs_to :project
  belongs_to :commit
end
