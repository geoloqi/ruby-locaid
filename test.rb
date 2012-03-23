require 'bundler/setup'
Bundler.require
require './lib/locaid.rb'

Savon.configure do |config|
  config.log = false
end

$config = YAML.load_file('./config.yml').inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

Locaid.defaults $config

# Locaid::Phone.from_phone_number attempts to convert a normal number to msisdn (which is what Locaid::Phone.new accepts).
phone = Locaid::Phone.from_phone_number 'PHONE_NUMBER_GOES_HERE'

if phone.opted_in? || phone.optin_pending?
  puts "GETTING LOCATION"
  puts phone.current_location
else
  puts "SENDING OPTIN REQUEST"
  puts phone.send_optin_request
end
