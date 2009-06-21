class Commit < ActiveRecord::Base
  validates_presence_of :identifier
  validates_uniqueness_of :identifier
  has_many :revisions, :dependent => :destroy
  has_many :projects, :through => :revisions
  has_many :bridges_as_parent, :class_name => "RevisionBridge", :foreign_key => :parent_id, :dependent => :destroy
  has_many :bridges_as_child, :class_name => "RevisionBridge", :foreign_key => :child_id, :dependent => :destroy
  has_many :children, :through => :bridges_as_parent, :class_name => "Commit"
  has_many :parents, :through => :bridges_as_child, :class_name => "Commit"

  def to_param
    identifier
  end

  def committer
    "#{committer_name} [#{committer_email}]"
  end

  def child_identifiers=(csv_identifier_list)
    bridges_as_parent.destroy_all && bridges_as_parent.reload
    identifiers = csv_identifier_list.split(",").map(&:strip)
    children << identifiers.flatten.map {|identifier| Commit.find_or_create_by_identifier(identifier)}
  end

  def parent_identifiers=(csv_identifier_list)
    bridges_as_child.destroy_all && bridges_as_child.reload
    identifiers = csv_identifier_list.split(",").map(&:strip)
    parents << identifiers.flatten.map {|identifier| Commit.find_or_create_by_identifier(identifier)}
  end

  def author
    "#{author_name} [#{author_email}]"
  end
end
