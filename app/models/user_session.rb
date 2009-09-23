class UserSession < Authlogic::Session::Base
  self.params_key = 'api_key'
end