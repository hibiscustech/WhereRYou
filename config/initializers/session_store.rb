# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_vishals_school_company_interaction_session',
  :secret      => 'a25e053469564c72bb952d1791835670db05d40b1f4e31e31ce85d03723a244dd9db086ceb712ac5c9364d034976fe2273baf85230868bea13a693ff33707bad'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
