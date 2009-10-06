class Plan < ActiveRecord::Base
  validates_presence_of :name, :visibility, :private_project_qty
  named_scope :visible, :conditions => {:visibility => "public"}

  def to_s
    name
  end
end
