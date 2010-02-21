class Build < ActiveRecord::Base
  FAILURE = "failure"
  SUCCESS = "success"
  NONE    = "nobuilds"

  belongs_to :commit

  named_scope :failing, :conditions => {:state => FAILURE}
  named_scope :passing, :conditions => {:state => SUCCESS}
end
