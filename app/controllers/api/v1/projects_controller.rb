class Api::V1::ProjectsController < ApplicationController
  def index
    @projects = Project.all

    respond_to do |format|
      format.xml {render :xml => @projects}
    end
  end

  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.xml {render :xml => @project, :status => :created, :location => api_v1_project_url(:xml, @project)}
      else
        format.xml {render :xml => @project.errors, :status => :unprocessable_entity}
      end
    end
  end
end
