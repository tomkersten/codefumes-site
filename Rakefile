# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'metric_fu'
require 'codefumes_harvester'

begin
  # NOTE: be sure to install vlad-git gem if you want to do deployments,
  # it is no longer included in vlad's core.
  require 'vlad'
  require 'hoe'
  Vlad.load :scm => :git
rescue LoadError
  # do nothing (in case server doesn't have Vlad, etc)
end

