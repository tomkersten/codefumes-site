class ExteriorController < ApplicationController
  def index
    return redirect_to(my_projects_path) if logged_in?
    @public_key = Project.generate_public_key
  end
end
