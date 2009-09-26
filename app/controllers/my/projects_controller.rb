class My::ProjectsController < My::BaseController
  def index
    @projects = current_user.projects
  end
end
