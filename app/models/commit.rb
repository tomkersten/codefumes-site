class Commit < ActiveRecord::Base
  validates_presence_of :identifier
  has_many :revisions, :dependent => :destroy
  has_many :projects, :through => :revisions

  def to_param
    identifier
  end
end
