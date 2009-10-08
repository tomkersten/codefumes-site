class UpgradeOpportunity < StandardError; end

class User < ActiveRecord::Base
  acts_as_authentic

  has_many :projects, :foreign_key => :owner_id
  has_many :subscriptions

  def claim(project, visibility=nil)
    if visibility == Project::PRIVATE && claiming_another_private_disallowed?
      raise UpgradeOpportunity, "#{self} (ID: #{self.id}) attempted to make private claim. Currently has '#{current_plan}' plan."
    end

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
  
  def to_s
    handle
  end

  def paying_customer?
    !current_subscription.nil?
  end

  def current_plan
    current_subscription && current_subscription.plan
  end

  def current_subscription
    most_recent = subscriptions.confirmed_or_cancelled.last
    most_recent && most_recent.confirmed? ? most_recent : nil
  end

  private
    def claiming_another_private_disallowed?
      return true if current_plan.blank?
      self.projects.private.count >= current_plan.private_project_qty
    end
end
