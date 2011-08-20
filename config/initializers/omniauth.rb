require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :facebook, '172218082831373', '98a2c55859b543633d4549b85be1c0cb'
  provider :facebook, '172218082831373', '98a2c55859b543633d4549b85be1c0cb'
  provider :linked_in, 'ht3xuvg87571', 'GK9fhGxhi9qnET42'
  provider :google_apps, OpenID::Store::Filesystem.new('/tmp')
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end