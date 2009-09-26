class My::BaseController < ApplicationController
  before_filter :require_user
end
