class Api::V1::ProjectsController < Api::BaseController

  def index
    @projects = Project.all
    respond_to do |format|
      format.xml {}
    end
  end

  def show
    respond_to do |format|
      if project.nil?
        format.xml {render :nothing => true, :status => :not_found}
      else
        format.xml {render :location => api_v1_project_url(:xml, project)}
      end
    end
  end

  def create
    @project = Project.new(project_request_params)

    respond_to do |format|
      if @project.save
        format.xml {render :status => :created, :location => api_v1_project_url(:xml, @project)}
      else
        format.xml {render :status => :unprocessable_entity, :xml => @project.errors}
      end
    end
  end

  def destroy
    project.destroy unless project.nil?
    respond_to do |format|
      format.xml {render :nothing => true}
    end
  end

  def update
    project_request_params.delete(:public_key)

    respond_to do |format|
      if !project.nil? && project.update_attributes(project_request_params)
        format.xml {render :location => api_v1_project_url(:xml, project)}
      else
        format.xml {render :nothing => true, :status => :unprocessable_entity}
      end
    end
  end

  private
    def project
      @project ||= Project.find_by_public_key(params[:id])
    end

    def project_request_params
      @req_params ||= params[:project] || {}
    end
end
