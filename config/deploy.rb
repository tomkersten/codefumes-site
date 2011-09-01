set :application, "ram.speechbanana.com"
set :user, "ram.speechbanana.com"
set :domain, "#{user}@speechbanana.com"
set :deploy_to, "/opt/research_data/websites/#{application}/website"
set :repository, 'git@code.research:ram.git'
set :branch, "origin/master"



#set :repository, 'git@github.com:tomkersten/codefumes-site.git'
#set :revision, "HEAD"
#
## To deploy specific branch
##set :revision, "origin/master"
## To deploy a specific tag "1.0"
##set :revision, "1.0"
#
#set :domain, "codefumes.com"
#set :application, "codefumes.com"
#set :deploy_to, "/opt/research_data/websites/codefumes.com/website"
#
#namespace :vlad do
#  Rake.clear_tasks('vlad:start_app')
##  set :web_command, "sudo /etc/init.d/apache2"
#
#  desc "Updates the symlinks for shared paths".cleanup
#  remote_task :update_symlinks, :roles => :app do
#    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/"
#  end
#
#  desc 'Restart Passenger'
#  remote_task :start_app, :roles => :app do
#    run "touch #{current_release}/tmp/restart.txt"
#  end
#
#  # Enhances existing update w/ chown/chmod commands
#  remote_task :update, :roles => :app do
#    run "cd #{release_path} && bundle install  --without test"
#    run "sudo chown -R http:www-data #{deploy_to}"
#    run "sudo chmod 775 -R #{deploy_to}"
#  end
#end
#
#desc "Deploys application, migrates db, symlinks, and cycles web/app servers"
#task :deploy => %w[vlad:update vlad:migrate vlad:start vlad:cleanup]
