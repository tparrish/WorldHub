# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_worldhub_session',
  :secret => '5fd39578b0b5f46861096fa1e4be603916c29302a5af268dda77944ddf51be6961f7ec6cbad6dec55c30576894c9f43ac52cdef567ef7d73435870999333ed41'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
