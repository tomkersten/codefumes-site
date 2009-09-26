# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'machinist/active_record'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require 'authlogic/test_case'

# This simplifies testing mailers with RSpec
# Read more here: http://github.com/bmabey/email-spec/tree/master
#require "email_spec/helpers"
#require "email_spec/matchers"

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # This simplifies testing mailers with RSpec
  # Read more here: http://github.com/bmabey/email-spec/tree/master
  #config.include(EmailSpec::Helpers)
  #config.include(EmailSpec::Matchers)

  # Resets machinist Shams before each test
  config.before(:each) do
    Sham.reset
  end
end

def setup_basic_auth(username, password)
  request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password).gsub(/\n/,'')
end

def login_as(persona_name)
  user = User.make(persona_name.to_sym)
  UserSession.create(:login => user.login, :password => User.plan(persona_name.to_sym))
  user
end
