class Api::V1::PayloadsController < Api::BaseController
  def create
    @payload = Payload.new(:content => params[:payload])

    respond_to do |format|
      if assign_to_project && @payload.save
        format.xml {render :status => :created, :location => api_v1_payload_url(@payload, :format => :xml)}
      else
        format.xml {render :status => :unprocessable_entity}
      end
    end
  end

  private
    def assign_to_project
      @payload.project = Project.find_by_public_key(params[:project_id])
      @payload.project
    end
end
