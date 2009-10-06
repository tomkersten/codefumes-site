class My::SubscriptionController < ApplicationController
  def new
    @subscription = current_user.subscriptions.new
    @visible_plans = Plan.visible
  end

  def create
    current_user.subscriptions.create(params[:subscription])
    redirect_to confirm_my_subscription_path
  end

  def confirm
    @subscription = current_user.subscriptions.last
  end

  def confirmed
    # process the transaction
    flash[:notice] = "Successfully updated your subscription"
    redirect_to my_projects_path
  end

  def edit
    @subscription = current_user.current_subscription.clone
    @visible_plans = Plan.visible
  end

  def cancel
  end

  def cancelled
    @subscription = current_user.current_subscription
    # cancel subscription
    flash[:notice] = "Your subscription has been cancelled."
    redirect_to my_projects_path
  end
end
