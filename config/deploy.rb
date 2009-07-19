set :repository, 'git@github.com:cosyn/codefumes-site.git'
set :revision, "HEAD"

# To deploy specific branch
#set :revision, "origin/master"
# To deploy a specific tag "1.0"
#set :revision, "1.0"

task :prod do
  set :domain, "codefumes.com"
  set :application, "codefumes_site"
  set :deploy_to, "/var/www/#{application}"
end

namespace :vlad do
  Rake.clear_tasks('vlad:start_app')
  set :web_command, "sudo /etc/init.d/apache2"

  desc "Updates the symlinks for shared paths".cleanup

  remote_task :update_symlinks, :roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/"
  end

  desc 'Restart Passenger'
  remote_task :start_app, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
