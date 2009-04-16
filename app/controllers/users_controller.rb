class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thanks for signing up!"
      redirect_to root_path
    else
      flash[:error] = "There was an error setting up your account."
      flash[:error] += "Please verify the supplied information and try again."
      render :action => :new
    end
  end
end
