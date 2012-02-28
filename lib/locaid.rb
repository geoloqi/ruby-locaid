require 'locaid/version'
require 'savon'
require 'hashie'
require 'hashie/mash'

module Locaid

  class << self
    def defaults(hash={})
      @defaults ||= {}
      return @defaults if hash.empty?
      @defaults = hash
    end
  end

  module Base
    BASE_WSDL_URL = 'https://ws.loc-aid.net:443/webservice'
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :savon_client
    end

    def initialize
      class_name = self.class.name.split('::').last
      @savon_client = Savon::Client.new { wsdl.document = "#{BASE_WSDL_URL}/#{class_name}?wsdl" }
    end

    private

    def request(meth, body_args)
      body = Locaid.defaults.merge body_args
      if body[:application_id]
        body['ClassID'] = body[:application_id]
        body.delete :application_id
      end

      response = @savon_client.request :wsdl, meth.to_s.lower_camelcase do
        soap.body = body
      end

      response.body["#{meth}_response".to_sym][:return]
    end
  end

  class RegistrationServices
    include Base
    
    def get_phone_status(*phone_numbers)
      
      phone_numbers.collect! do |num|
        num.gsub!(/\D/, '')
        num.strip!
        if num.length < 11
          puts "WARNING: phone number is expected to be in MSISDN format (http://en.wikipedia.org/wiki/MSISDN)."+
               " We will default to the United States."
          num = "1#{num}"
        end
        num
      end

      response = request :get_phone_status, {
        msisdn_list:     phone_numbers
      }

      response
    end
    
  end
end

=begin
# ,
#        location_method: (gps ? 'MOST_ACCURATE' : 'LEAST_EXPENSIVE'),
#        coor_type:       'DECIMAL',
#        sync_type:       'syn' # This can be made async with some work, if needed
=end
