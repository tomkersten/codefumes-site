class My::AccountController < My::BaseController
  def show
    @user = current_user
  end
end