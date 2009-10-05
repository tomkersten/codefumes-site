class Plan < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :visibility
  named_scope :visible, :conditions => {:visibility => "public"}

  def to_s
    name
  end
end
