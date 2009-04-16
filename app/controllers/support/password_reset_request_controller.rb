class Support::PasswordResetRequestController < ApplicationController
  before_filter :require_no_user

  def new
    render
  end

  def create
    @user = User.find_by_email(supplied_email)
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "We have emailed you a link to reset your password which expires in 10 minutes. "
      flash[:notice] += "Don't worry if you can't get to it right away...you can restart this process as many times as you need to."
      redirect_to root_url
    else
      flash[:error] = "No user was found with that email address"
      render :action => :new
    end
  end

  def edit
    unless user_found_using_perishable_token
      deny_request_and_send_to_home_page
    end
  end

  def update
    if user_not_found_using_perishable_token
      deny_request_and_send_to_home_page && return
    end

    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated"
      redirect_to root_path
    else
      flash[:error] = "Your password was not updated."
      render :action => :edit
    end
  end

  private
    def supplied_email
      params[:user] && params[:user][:email]
    end

    def user_found_using_perishable_token
      @user ||= User.find_using_perishable_token(params[:id])
    end

    def user_not_found_using_perishable_token
      user_found_using_perishable_token.nil?
    end

    def deny_request_and_send_to_home_page
      flash[:error] = "We're sorry, but we could not locate your account. " +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to root_url
    end
end
