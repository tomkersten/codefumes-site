class My::AccountController < My::BaseController
  def show
    @user = current_user
  end

  def update
    current_user.update_attributes(params[:user])
    flash[:notice] = "Your password has been updated"
    redirect_to(my_account_path)
  end
end
