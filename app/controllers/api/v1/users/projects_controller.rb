class Api::V1::Users::ProjectsController < Api::BaseController
  def index
    @projects = user.projects.public
    render :file => 'api/v1/projects/index.xml.haml'
  end

  private
    def user
      @user ||= User[params[:user_id]]
    end
end
