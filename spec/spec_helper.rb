# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

#CUSTOMIZATIONS
require 'machinist/active_record'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require 'authlogic/test_case'
require 'webrat'
#/CUSTOMIZATIONS


# Uncomment the next line to use webrat's matchers
require 'webrat/integrations/rspec-rails'

#CUSTOMIZATIONS
Webrat.configure do |config|
  config.mode = :rails
end
#/CUSTOMIZATIONS

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}


module CodeFumesSpecHelpers
  module Authentication
    def setup_basic_auth(username, password)
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password).gsub(/\n/,'')
    end

    def login_as(persona_name)
      user = User.find_by_email(User.plan(persona_name.to_sym)[:email]) || User.make(persona_name.to_sym)
      UserSession.create(:login => user.login, :password => User.plan(persona_name.to_sym))
      user
    end
  end
end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include(Webrat::Matchers, :type => [:integration])
  config.include(CodeFumesSpecHelpers::Authentication, :type => [:controller])
end

class ActionController::Integration::Session; include Spec::Matchers; end
