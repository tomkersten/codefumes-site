# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support

# This adds support for email matchers in cucumber
# Read more here: http://github.com/bmabey/email-spec/tree/master
require 'email_spec/cucumber'

# Loads blueprints for machinist
require File.expand_path(File.dirname(__FILE__) + "/../../spec/blueprints")

Cucumber::Rails.use_transactional_fixtures

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

# Comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps.
require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
