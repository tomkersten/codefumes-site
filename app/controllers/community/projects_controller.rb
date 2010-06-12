class Community::ProjectsController < ApplicationController
  def show
    @project = Project.find(:first, :conditions => ["public_key = ?", params[:id]])
    respond_to do |format|
      format.html
      format.js {render :json => @project.to_json(:include => [:commits], :methods => [:build_status])}
    end
  end

  def short_uri
    @project = Project.find_by_public_key(params[:public_key])

    redirect_to(invalid_project_path)  && return if @project.nil?
  end

  def acknowledge
    @project = Project[params[:id]]
    @project.acknowledge_visibility!
    redirect_to short_uri_path(@project)
  end
end
