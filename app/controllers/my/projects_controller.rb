class My::ProjectsController < My::BaseController
  def index
    @projects = current_user.projects
  end

  def edit
    load_project
  end

  def update
    project.update_attributes(project_params)
    flash[:notice] = "Project details updated successfully."
    redirect_to short_uri_path(@project)

    rescue ActiveRecord::RecordNotFound
      flash[:error] = "You do not have permission to edit that project."
      redirect_to my_projects_path
  end

  def set_visibility
    project.set_visibility_to(project_params[:visibility])
    redirect_to short_uri_path(project)
  end

  def destroy
    project.destroy
    flash[:notice] = "'#{project}' project and associated content has been removed."
    redirect_to my_projects_path
  end

  private
    def project
      @project ||= current_user.projects[params[:id]]
    end
    alias_method :load_project, :project

    def project_params
      params[:project] || {}
    end
end
