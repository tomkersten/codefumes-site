class Api::V1::ClaimController < Api::BaseController
  before_filter :require_user
  before_filter :require_project_unclaimed, :only => :create
  before_filter :require_project_unclaimed_or_owned, :only => :destroy
  
  def create
    current_user.claim(project)
    respond_to do |format|
      format.xml {render :status => :created, :nothing => true}
    end
  end

  def destroy
    current_user.relinquish_claim(project)
    respond_to do |format|
      format.xml {head :ok}      
    end
  end
  
  private
    def single_access_allowed?
      true
    end
  

end
