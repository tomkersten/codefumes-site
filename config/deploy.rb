set :application, "codefumes.com"
set :user, "codefumes.com"
set :domain, "#{user}@codefumes.com"
set :deploy_to, "/opt/research_data/websites/#{application}/website"
set :repository, 'git@github.com:tomkersten/codefumes-site.git'
set :branch, "origin/master"
