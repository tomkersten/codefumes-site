class ExteriorController < ApplicationController
  def index
    @public_key = Project.generate_public_key
  end
end
