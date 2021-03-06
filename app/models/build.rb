class Build < ActiveRecord::Base
  RUNNING    = "running"
  FAILED     = "failed"
  SUCCESSFUL = "successful"

  validates_presence_of :name, :started_at
  validates_uniqueness_of :name, :scope => :commit_id
  validates_format_of :state,
                      :with => /#{RUNNING}|#{FAILED}|#{SUCCESSFUL}/,
                      :message => "must be one of the following: #{RUNNING}, #{FAILED}, #{SUCCESSFUL}"

  belongs_to :commit

  named_scope :failing, :conditions => {:state => FAILED}
  named_scope :passing, :conditions => {:state => SUCCESSFUL}
  named_scope :running, :conditions => {:state => RUNNING}

  def duration
    if state != RUNNING
      ended_at - started_at
    else
      Time.now - started_at
    end
  end
  alias_method :average_build_duration, :duration
end
