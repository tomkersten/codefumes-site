class My::ProjectsController < My::BaseController
  def index
    @projects = current_user.projects
  end

  def edit
    load_project
  end

  def update
    project.update_attributes(params[:project])
    redirect_to short_uri_path(@project)

    rescue ActiveRecord::RecordNotFound
      flash[:error] = "You do not have permission to edit that project."
      redirect_to my_projects_path
  end

  private
    def project
      @project ||= current_user.projects[params[:id]]
    end
    alias_method :load_project, :project
end
