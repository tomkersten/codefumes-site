class Api::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :require_project_authorization
  
  private
    def project
      @project ||= Project.find_by_public_key(params[:project_id])
    end
    
    def require_project_authorization
      return true if request.get? || project.blank? || authenticate_with_http_basic{|pub, priv| project.public_key == pub && project.private_key == priv}
      
      respond_to do |format|
        format.xml {render :status => :unauthorized}
      end
      
      return false
    end
  
end
