class Api::V1::BuildsController < Api::BaseController
  def index
    @builds = commit.builds
  end

  def show
    respond_to do |format|
      if build.nil?
        format.xml {render :nothing => true, :status => :not_found}
      else
        format.xml {render :location => api_v1_project_commit_build_url(:xml, project, commit, build)}
      end
    end
  end

  def create
    @build = commit.builds.new(build_params)

    respond_to do |format|
      if @build.save
        format.xml {render :status => :created, :location => api_v1_project_commit_build_url(:xml, project, commit, build)}
      else
        format.xml {render :status => :unprocessable_entity}
      end
    end
  end

  def update
    respond_to do |format|
      if build && build.update_attributes(build_params)
        format.xml {render :location => api_v1_project_commit_build_url(:xml, project, commit, build)}
      else
        format.xml {render :status => :unprocessable_entity, :location => api_v1_project_commit_build_url(:xml, project, commit, build)}
      end
    end
  end

  def destroy
    build && build.destroy
    respond_to do |format|
      format.xml {render :nothing => true}
    end
  end

  private
    def commit
      @commit ||= project.commits.find_by_identifier(params[:commit_id])
      @commit.nil? ? project.commits.create!(:identifier => params[:commit_id]) : @commit
    end

    def build
      @build ||= commit.builds.find_by_id(params[:id])
    end

    def build_params
      @build_params ||= params[:build]
    end
end
