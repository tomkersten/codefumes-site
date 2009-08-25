# Settings specified here will take precedence over those in config/environment.rb
config.gem 'webrat', :lib => false
config.gem 'rspec-rails', :lib => false, :version => '>= 1.2.2'
config.gem 'rspec', :lib => false, :version => '>= 1.2.2'
config.gem 'cucumber', :version => ">= 0.2.0"
config.gem 'ZenTest', :lib => 'zentest'
config.gem 'builder'
config.gem 'diff-lcs', :lib => 'diff/lcs'
config.gem 'nokogiri'
config.gem 'treetop'
config.gem 'term-ansicolor', :lib => 'term/ansicolor'
config.gem 'notahat-machinist', :lib => 'machinist', :source => 'http://gems.github.com', :version => '>= 1.0.3'
config.gem 'faker', :version => '>= 0.3.1'
config.gem 'bmabey-email_spec', :lib => 'email_spec', :source => 'http://gems.github.com'
config.gem 'jscruggs-metric_fu', :version => '1.1.5', :lib => 'metric_fu', :source => 'http://gems.github.com'
config.gem 'topfunky-gruff', :version => '0.3.5', :lib => 'gruff', :source => 'http://gems.github.com'
config.gem 'flay', :version => ">= 1.3.0"
config.gem 'sexp_processor', :version => ">= 3.0.1"
config.gem 'ruby_parser', :version => ">= 2.0.2"
config.gem 'flog', :version => ">= 2.1.2"
config.gem 'relevance-rcov', :version => ">= 0.8.3.4", :lib => 'rcov'
config.gem 'mojombo-chronic', :version => ">= 0.3.0", :source => 'http://gems.github.com', :lib => 'chronic'

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

config.action_mailer.default_url_options = {:host => 'localhost'}
