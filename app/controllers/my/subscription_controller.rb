class My::SubscriptionController < ApplicationController
  def new
    @subscription = current_user.subscriptions.new
  end

  def create
    subscription = current_user.subscriptions.create(params[:subscription])
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
end
