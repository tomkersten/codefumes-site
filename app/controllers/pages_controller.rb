class PagesController < ApplicationController
  rescue_from ActionView::MissingTemplate, :with => :invalid_page

  def index
    return redirect_to(my_projects_path) if logged_in?
    @public_key = Project.generate_public_key
  end

  def show
    render :template => current_page
  end

  def invalid_public_key
  end

  protected
    def invalid_page
      render :nothing => true, :status => 404
    end

    def current_page
      ['pages', params[:dir], params[:template_name].to_s.downcase].compact.join('/')
    end
end
