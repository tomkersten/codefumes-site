class Community::ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
  end

  def short_uri
    project = Project.find_by_public_key(params[:public_key])
    unless project.nil?
      redirect_to community_project_path(project)
      return
    end
  end
end
