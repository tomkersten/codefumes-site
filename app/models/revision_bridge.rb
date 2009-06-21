class RevisionBridge < ActiveRecord::Base
  validates_uniqueness_of :parent_id, :scope => :child_id
  validates_uniqueness_of :child_id,  :scope => :parent_id

  before_validation :prevent_self_references

  belongs_to :parent, :class_name => "Commit"
  belongs_to :child, :class_name => "Commit"

  private
    def prevent_self_references
      return false if parent_id == child_id
    end
end
