class Commit < ActiveRecord::Base
  validates_presence_of :identifier
  has_many :revisions, :dependent => :destroy
  has_many :projects, :through => :revisions

  def to_param
    identifier
  end

  def committer
    "#{committer_name} [#{committer_email}]"
  end

  def author
    "#{author_name} [#{author_email}]"
  end
end
