class Community::AttributesController < ApplicationController
  def show
    @attribute = params[:attribute]
    @project = Project[params[:public_key]]
    @commits = @project && @project.recent_commits

    respond_to do |format|
       format.html
       format.js {render :json => @project.custom_attribute_data(@attribute)}
     end
  end
end
