class Build < ActiveRecord::Base
  FAILURE = "failure"
  SUCCESS = "success"
  RUNNING = "running"

  validates_presence_of :name, :started_at
  validates_uniqueness_of :name, :scope => :commit_id
  validates_format_of :state,
                      :with => /#{FAILURE}|#{SUCCESS}|#{RUNNING}/,
                      :message => "must be one of the following: #{FAILURE}, #{SUCCESS}, #{RUNNING}"

  belongs_to :commit

  named_scope :failing, :conditions => {:state => FAILURE}
  named_scope :passing, :conditions => {:state => SUCCESS}
  named_scope :running, :conditions => {:state => RUNNING}
end
