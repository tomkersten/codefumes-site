class Build < ActiveRecord::Base
  FAILURE = "failure"
  SUCCESS = "success"
  NONE    = "nobuilds"

  validates_presence_of :name, :started_at
  validates_uniqueness_of :name, :scope => :commit_id

  belongs_to :commit

  named_scope :failing, :conditions => {:state => FAILURE}
  named_scope :passing, :conditions => {:state => SUCCESS}
end
