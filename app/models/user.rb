class User < ActiveRecord::Base
  acts_as_authentic

  has_many :projects

  def claim(project)
    projects << project
  end  

  def relinquish_claim(project)
    projects.delete(project)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def handle
    email
  end
end
