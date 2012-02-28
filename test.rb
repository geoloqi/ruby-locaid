require 'bundler/setup'
Bundler.require
require './lib/locaid.rb'

Savon.configure do |config|
  config.log = false
end

$config = YAML.load_file('./config.yml').inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

Locaid.defaults $config
puts "CONFIG: #{Locaid.defaults}"

# Get phone status
# response = rs.get_phone_status 'PHONENUMBER'
# puts response.inspect

phone = Locaid::Phone.new '6126191'

puts phone.status.inspect
#puts phone.opt_in

=begin
# ,
#        location_method: (gps ? 'MOST_ACCURATE' : 'LEAST_EXPENSIVE'),
#        coor_type:       'DECIMAL',
#        sync_type:       'syn' # This can be made async with some work, if needed
=end
