class Api::V1::ProjectsController < ApplicationController
  def index
    @projects = Project.all
    respond_to do |format|
      format.xml {}
    end
  end

  def show
    respond_to do |format|
      if project.nil?
        format.xml {render :status => :not_found}
      else
        format.xml {render :location => api_v1_project_url(:xml, project)}
      end
    end
  end

  def create
    clean_up_request_params
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        format.xml {render :status => :created, :location => api_v1_project_url(:xml, @project)}
      else
        format.xml {render :xml => @project.errors, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @project ||= Project.find_by_public_key(params[:id])
    @project.destroy unless @project.nil?
    respond_to do |format|
      format.xml {render :text => nil }
    end
  end

  def update
    if project.nil?
      create
    else
      clean_up_request_params
      respond_to do |format|
        if project.update_attributes(params[:project])
          format.xml {render :location => api_v1_project_url(:xml, project)}
        else
          format.xml {render :status => :unprocessable_entity, :location => api_v1_project_url(:xml, project)}
        end
      end
    end
  end

  private
    def project
      @project ||= Project.find(:first, :conditions => ["public_key = ?", params[:id]])
    end

    def project_request_params
      params[:project] || {}
    end

    def clean_up_request_params
      if request.post?
        project_request_params.delete(:public_key)
      elsif request.put?
        project_request_params[:public_key] = params[:id]
      end
    end
end
