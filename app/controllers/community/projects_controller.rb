class Community::ProjectsController < ApplicationController
  def show
    @project = Project.find(:first, :conditions => ["public_key = ?", params[:id]])
    respond_to do |format|
      format.html
      format.js {render :json => @project.to_json(:include => [:commits])}
    end
  end

  def short_uri
    @project = Project.find_by_public_key(params[:public_key])
  end
end
