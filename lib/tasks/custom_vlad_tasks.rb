begin
  require 'vlad'
rescue LoadError; end

if defined?(Vlad)
  desc "Deploy HEAD (with migrations)"
  task :deploy => ['deploy:update_code', 'deploy:migrate_db', 'deploy:cycle_app_servers']

  namespace :deploy do
    desc "Set up project on server"
    remote_task :setup do
      puts "##### Cloning repository to '#{deploy_to}' on server and running 'bundle install'..."
      run "git clone #{repository} #{deploy_to} && cd #{deploy_to} && bundle install --without=development test rake && cp config/server/database.yml config/"
    end

    desc "Update the codebase to HEAD"
    remote_task :update_code do
      puts "##### Deploying commit: #{branch}..."
      run "cd #{deploy_to} && git fetch origin && git reset --hard #{branch} && bundle install --without=development test rake"
    end

    desc "Migrate the database"
    remote_task :migrate_db do
      puts "##### Migrating the database..."
      run "export RAILS_ENV=production && cd #{deploy_to} && bundle exec rake db:migrate"
    end

    desc "Restarts application server(s)"
    remote_task :cycle_app_servers do
      puts "##### Cycling herd..."
      run "cd #{deploy_to}; #{application} restart"
    end

    desc "Restarts web server (nginx) (uses sudo)"
    remote_task :cycle_web_server do
      puts "##### Cycling nginx..."
      run "sudo /etc/init.d/nginx restart"
      puts "##### Cycling nginx completed successfully..."
    end

    desc "Rollback the codebase to {@1}"
    remote_task :rollback do
      puts "##### Rolling back deployment..."
      set :branch, "HEAD@{1}"
      Rake::Task[:deploy].invoke
    end

    desc "Show which commits would be deployed right now"
    remote_task :what do
      print "(Locally) Fetching current state of origin..."
      `git fetch origin`
      origin_master_head = `cat .git/refs/remotes/origin/master`.chomp
      origin_head_details = `git log #{origin_master_head} --pretty=oneline -n 1`
      puts origin_master_head

      print "Current commit on server is..."
      production_head = run("cd #{deploy_to} > /dev/null 2>&1 && cat .git/refs/heads/master").chomp
      puts ""

      if origin_master_head == production_head
        puts "Server is in sync with origin/master...no need to deploy"
      else
        puts "If you deploy now, the following commits will be added to prod:"
        puts `git log #{production_head}..#{origin_master_head} --oneline  --abbrev-commit`
      end
    end
  end
end

