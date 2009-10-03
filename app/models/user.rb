class User < ActiveRecord::Base
  acts_as_authentic

  has_many :projects, :foreign_key => :owner_id

  def claim(project, visibility=nil)
    project.visibility = visibility if visibility
    if project.save
      projects << project
      true
    else
      project.reload
      false
    end
  end  

  def relinquish_claim(project)
    if project.owner == self
      projects.delete(project)
      project.visibility = Project::PUBLIC 
      project.save
      project.reload
    end
    true
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def handle
    login
  end
end
