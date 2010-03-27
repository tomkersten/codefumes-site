class Build < ActiveRecord::Base
  RUNNING = "running"
  FAILURE = "failed"
  SUCCESS = "success"

  validates_presence_of :name, :started_at
  validates_uniqueness_of :name, :scope => :commit_id
  validates_format_of :state,
                      :with => /#{RUNNING}|#{FAILURE}|#{SUCCESS}/,
                      :message => "must be one of the following: #{RUNNING}, #{FAILURE}, #{SUCCESS}"

  belongs_to :commit

  named_scope :failing, :conditions => {:state => FAILURE}
  named_scope :passing, :conditions => {:state => SUCCESS}
  named_scope :running, :conditions => {:state => RUNNING}
end
