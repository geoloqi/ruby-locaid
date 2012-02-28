require 'locaid/phone'
require 'locaid/error'
require 'locaid/api_error'
require 'locaid/version'
require 'savon'
require 'hashie'
require 'hashie/mash'

module Locaid
  BASE_WSDL_URL = 'https://ws.loc-aid.net:443/webservice'

  class << self
    def defaults(hash={})
      @defaults ||= {}
      return @defaults if hash.empty?
      @defaults = hash
    end
  end
end