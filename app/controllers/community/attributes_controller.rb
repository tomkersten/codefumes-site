class Community::AttributesController < ApplicationController
  def show
    @attribute = params[:attribute]
    @project = Project.find(:first, :conditions => ["public_key = ?", params[:public_key]])
    
    respond_to do |format|
       format.html
       format.js {render :json => @project.custom_attribute_data(@attribute)}
     end
  end
end
