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
