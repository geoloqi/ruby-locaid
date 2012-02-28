require 'bundler/setup'
Bundler.require
require './lib/locaid.rb'

Savon.configure do |config|
  config.log = false
end

$config = YAML.load_file('./config.yml').inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

Locaid.defaults $config

phone = Locaid::Phone.new 'PHONE_NUMBER'

if phone.opted_in? || phone.optin_pending?
  puts phone.current_location
else
  puts phone.send_optin_request
end
