class User < ActiveRecord::Base
  acts_as_authentic

  has_many :projects, :foreign_key => :owner_id
  has_many :subscriptions

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

  def paying_customer?
    !current_subscription.nil?
  end

  def current_plan
    current_subscription.plan
  end

  def current_subscription
    most_recent = subscriptions.confirmed_or_cancelled.last
    most_recent && most_recent.confirmed? ? most_recent : nil
  end
end
