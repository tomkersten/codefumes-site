class User < ActiveRecord::Base
  acts_as_authentic

  has_many :projects, :foreign_key => :owner_id, :order => [:privatized_at] do
    def [](acceptable_search_key)
      public_key = case acceptable_search_key
                     when String : acceptable_search_key
                     when Project : acceptable_search_key.public_key
                     else raise ArgumentError
                   end
      returning(find(:first, :conditions => {:public_key => public_key})) do |result|
        raise ActiveRecord::RecordNotFound if result.nil?
      end
    end
  end

  has_many :subscriptions

  def claim(project, visibility=nil)
    project.visibility = visibility if visibility
    project.privatized_at = Time.now
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
      project.privatized_at = nil
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

  def covered_projects
    return [] if current_subscription.nil? || projects.private.empty?
    projects.private.find(:all, :limit => current_plan.private_project_qty)
  end
end
