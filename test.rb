require 'bundler/setup'
Bundler.require
require './lib/locaid.rb'

Savon.configure do |config|
  config.log = false
end

$config = YAML.load_file('./config.yml').inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

Locaid.defaults $config

rs = Locaid::RegistrationServices.new
response = rs.get_phone_status 'PHONENUMBER'
puts response.inspect
