require 'bundler/setup'
Bundler.require

# Register the phone

$client = Savon::Client.new do
  wsdl.document = 'https://ws.loc-aid.net:443/webservice/RegistrationServices?wsdl'
end

puts $client.inspect

$client.request :wsdl, :getPhoneStatus


#$client.request :getLocationsX, {'ClassID' => 'KNSR2', 'login' => 'kyledrake@gmail.com', 'password' => '4884kD'}


#require 'ruby-debug' ; debugger