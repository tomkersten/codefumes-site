class My::SubscriptionController < My::BaseController
  def new
    @subscription = current_user.subscriptions.new(:plan => Plan.first)
    @visible_plans = Plan.visible
  end

  def create
    current_user.subscriptions.create!(params[:subscription])
    redirect_to confirm_my_subscription_path
  end

  def confirm
    @subscription = current_user.subscriptions.unconfirmed.last
  end

  def confirmed
    @subscription = current_user.subscriptions.unconfirmed.last
    @subscription.confirm!
    flash[:notice] = "Your subscription has been updated."
    redirect_to my_account_path
  end

  def edit
    @subscription = current_user.current_subscription.clone
    @visible_plans = Plan.visible
  end

  def cancel
  end

  def cancelled
    @subscription = current_user.current_subscription
    @subscription.cancel! unless @subscription.blank?
    flash[:notice] = "Your subscription has been cancelled"
    redirect_to my_account_path
  end
end
