# Ruby Locaid Gem
A ruby gem for working with the Locaid location API.

## Example

    require 'bundler/setup'
    Bundler.require
    require './lib/locaid.rb'

    Locaid.defaults login: 'YOUR LOGIN', password: 'YOUR PASSWORD', application_id: 'YOUR APP ID'

    # Locaid::Phone.from_phone_number attempts to convert a normal number to msisdn (which is what Locaid::Phone.new accepts).
    phone = Locaid::Phone.from_phone_number 'PHONE NUMBER GOES HERE'

    if phone.opted_in? || phone.optin_pending?
      puts phone.current_location
    else
      puts phone.send_optin_request
    end
