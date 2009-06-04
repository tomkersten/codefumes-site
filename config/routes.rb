ActionController::Routing::Routes.draw do |map|
  map.signup '/signup',  :controller => 'users', :action => 'new', :method => :get
  map.confirm_logout '/logout/confirm', :controller => 'session', :action => 'confirm_logout', :method => :get
  map.logout '/logout', :controller => 'session', :action => 'destroy', :method => :delete
  map.login  '/login',  :controller => 'session', :action => 'new', :method => :get

  map.short_uri '/p/:public_key', :controller => 'Community::Projects', :action => 'short_uri', :method => :get
  map.namespace :community do |community|
    community.resources :projects
  end

  map.resources :users
  map.resource :session, :controller => 'session'
  map.root :controller => 'exterior'

  map.namespace :api do |api|
    api.namespace :v1 do |v1|
      v1.resources :projects, :path_prefix => '/api/v1/:format' do |project|
        project.resources :payloads, :shallow => true
        project.resources :commits, :shallow => true, :collection => {:latest => :get}
      end
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
