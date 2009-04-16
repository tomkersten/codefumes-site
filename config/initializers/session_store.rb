# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_website_session',
  :secret      => 'a62178b7be58a9fffa913ae9a40b2979e68757847b5e626428f30268c7d34338ae3b91318df9fa6dd947f9faa5c7aecbd8584e82678af4b63945e6195167aa2b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
