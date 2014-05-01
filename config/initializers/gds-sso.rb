GDS::SSO.config do |config|
  config.user_model   = 'User'
  config.oauth_id     = 'release_oauth_id_defined_on_rollout'
  config.oauth_secret = 'secret'
  config.oauth_root_url = Plek.current.find("signon")
end
