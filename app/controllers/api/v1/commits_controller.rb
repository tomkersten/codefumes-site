class Api::V1::CommitsController < ApplicationController
  def index
    @commits = project.commits
    respond_to do |format|
      format.xml
    end
  end

  def show
    @commit = project.commits.find_by_identifier(params[:id])
    respond_to do |format|
      if @commit.nil?
        format.xml {render :nothing => true, :status => :not_found}
      else
        format.xml {render :location => api_v1_commit_url(@commit)}
      end
    end
  end

  def latest
    @commit = project.commit_head

    respond_to do |format|
      format.xml {render :action => :show, :location => api_v1_commit_url(@commit)}
    end
  end

  private
    def project
      @project ||= Project.find_by_public_key(params[:project_id])
    end
end
