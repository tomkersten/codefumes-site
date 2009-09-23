class Api::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :require_project_authorization
  
  private
    def project
      @project ||= Project.find_by_public_key(params[:project_id])
    end
    
    def require_project_authorization
      unless request.get? || project.blank? || authenticate_with_http_basic{|pub, priv| project.public_key == pub && project.private_key == priv}
        return unauthorized
      end
    end
    
    def require_user
      unless current_user
        return unauthorized
      end
    end
    
    def require_project_unclaimed
      return unauthorized if project.claimed?
    end
    
    def require_project_unclaimed_or_owned
      return unauthorized if project.claimed? && project.user != current_user
    end
    
    def unauthorized
      respond_to do |format|
        format.xml {render :status => :unauthorized, :nothing => true}
      end
      false
    end
end
