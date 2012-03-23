require 'locaid/phone'
require 'locaid/error'
require 'locaid/api_error'
require 'locaid/version'
require 'savon'
require 'hashie'
require 'hashie/mash'
require 'thread'
require 'rest-client'

module Locaid
  BASE_WSDL_URL = 'https://ws.loc-aid.net:443/webservice'
  @@wsdl_cache = {}

  class << self
    def defaults(hash={})
      @defaults ||= {}

      if hash.empty?
        return @defaults
      else
        @defaults = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end
    end
    
    def wsdl_cache(url)
      if @@wsdl_cache[url]
        return @@wsdl_cache[url]
      else
        wsdl_cache = RestClient.get url

        Mutex.new.synchronize do
          @@wsdl_cache[url] = wsdl_cache
        end
        
        return wsdl_cache
      end
    end

  end
end