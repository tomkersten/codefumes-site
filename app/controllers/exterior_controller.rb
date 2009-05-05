class ExteriorController < ApplicationController
  def index
    @project_key = Project.generate_key
  end
end
