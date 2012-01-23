# require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, APP_CONFIG[:twitter_key], APP_CONFIG[:twitter_secret]
  provider :facebook, APP_CONFIG[:facebook_key], APP_CONFIG[:facebook_secret]
  provider :linked_in, APP_CONFIG[:linked_in_key], APP_CONFIG[:linked_in_secret]
  # provider :google_apps, OpenID::Store::Filesystem.new('/tmp')
  # provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end