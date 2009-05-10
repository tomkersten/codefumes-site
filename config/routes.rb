ActionController::Routing::Routes.draw do |map|
  map.signup '/signup',  :controller => 'users', :action => 'new', :method => :get
  map.confirm_logout '/logout/confirm', :controller => 'session', :action => 'confirm_logout', :method => :get
  map.logout '/logout', :controller => 'session', :action => 'destroy', :method => :delete
  map.login  '/login',  :controller => 'session', :action => 'new', :method => :get


  map.resources :users
  map.resource :session, :controller => 'session'
  map.root :controller => 'exterior'

  map.namespace :api do |api|
    api.namespace :v1 do |v1|
      v1.resources :projects, :path_prefix => '/api/v1/:format'
    end
  end

  map.namespace :support do |support|
    support.resource :password_reset_request, :controller => "PasswordResetRequest"
  end

  # For some reason these seem to be required for RSpec to recognize namespaced
  # routes correctly
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
