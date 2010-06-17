ActionController::Routing::Routes.draw do |map|
  # Static pages
  map.page 'pages/:template_name', :controller => 'pages', :action => 'show'
  map.howto_page 'howto/:template_name', :controller => 'pages', :action => 'show', :dir => 'howto'

  map.signup '/signup',  :controller => 'users', :action => 'new', :method => :get
  map.confirm_logout '/logout/confirm', :controller => 'session', :action => 'confirm_logout', :method => :get
  map.logout '/logout', :controller => 'session', :action => 'destroy', :method => :delete
  map.login  '/login',  :controller => 'session', :action => 'new', :method => :get

  map.invalid_project '/what', :controller => 'pages', :action => 'invalid_public_key', :method => :get

  map.short_uri '/p/:public_key', :controller => 'Community::Projects', :action => 'short_uri', :method => :get
  map.show_project_attributes '/p/:public_key/attributes/:attribute.:format', :controller => 'Community::Attributes', :action => 'show', :method => :get
  
  map.resources :p, :controller => 'Community::Projects' 
  map.namespace :community do |community|
    community.resources :projects, :member => {:acknowledge => :get}
  end

  map.namespace :my do |my|
    my.resources :projects, :member => {:set_visibility => :put}
    my.resource :account, :controller => "account"
    my.resource :subscription,  :controller => "subscription",
                                :member => {
                                            :confirm => :get,
                                            :confirmed => :post,
                                            :cancel => :get,
                                            :cancelled => :put
                                           }
  end

  map.resources :users
  map.resource :session, :controller => 'session'
  map.root :controller => 'pages'

  map.api_v1_commit '/api/v1/:format/commits/:id', :controller => "Api::V1::Commits", :action => 'show', :method => :get
  map.api_v1_user_projects '/api/v1/:format/users/:user_id/projects',
                            :controller => "Api::V1::Users::Projects",
                            :action => 'index',
                            :method => :get

  map.namespace :api do |api|
    api.namespace :v1 do |v1|
      v1.resources :projects, :path_prefix => '/api/v1/:format' do |project|
        project.resource  :claim, :controller => "Claim"
        project.resources :payloads, :shallow => true
        project.resources :commits, :collection => {:latest => :get} do |commit|
          commit.resources :builds
        end
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
