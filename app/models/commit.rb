class Commit < ActiveRecord::Base
  has_many :revisions, :dependent => :destroy
  has_many :projects, :through => :revisions
end
