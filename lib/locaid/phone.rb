module Locaid
  class Phone
    def self.phone_number_to_msisdn(number)
      number = number.to_s
      number.gsub! /[^0-9]/, ''
      number = "1#{number}" if number.length == 10
      number
    end

    # Locaid::Phone.from_phone_number attempts to convert a normal number to msisdn (which is what Locaid::Phone.new accepts).
    #
    # This strips out any non-number characters. It will also add a 1 to the front of the number if the size is 10 characters, 
    # with the assumption that it is a US number.
    #
    # It may be helpful to convert the characters to their respective numbers as well.
    def self.from_phone_number(number)
      new phone_number_to_msisdn(number)
    end

    def initialize(msisdn)
      @msisdn = msisdn
    end

    # NONE, means that the requested msisdn has no previous OPTIN record.
    # OPTIN_PENDING, means that the OPTIN command for that classID was given, but no YES/NO response was given.
    # CANCELLED, means that the requested msisdn is unsubscribed from that classId.
    # OPTIN_COMPLETE, means that the requested msisdn is subscribed to that classId.

    def status(cache=true)
      return @status if @status && cache

      resp = request :registration_services, :get_phone_status, {
        msisdn_list:     [@msisdn]
      }

      if !resp[:msisdn_list][:status].nil?
        status = resp[:msisdn_list][:status]
      elsif resp[:msisdn_list][:class_id_list].is_a? Hash
        status = resp[:msisdn_list][:class_id_list][:status]
      else
        raise Error, 'could not process status response'
      end

      @status = status.downcase.to_sym
    end

    def opted_in?;        status == :optin_complete  end
    def optin_pending?;   status == :optin_pending   end
    def optin_cancelled?; status == :optin_cancelled end
    def opted_in?;        status == :optin_complete  end

    def send_optin_request
      resp = request :registration_services, :subscribe_phone, {
        command: 'OPTIN',
        class_id_list: [{
          class_id: Locaid.defaults[:application_id],
          msisdn_list: [@msisdn],
        }]
      }

      resp[:class_id_list][:msisdn_list][:status] == 'OK'
    end

    def current_location(high_accuracy=true)
      res = request :latitude_longitude_services, :get_locations_x, {
        class_id: Locaid.defaults[:application_id],
        msisdn_list:     [@msisdn],
        location_method: (high_accuracy ? 'MOST_ACCURATE' : 'LEAST_EXPENSIVE'),
        coor_type:       'DECIMAL',
        sync_type:       'syn' # This can be made async with some work, if needed
      }
      res
    end

    private

    def request(resource, meth, body_args)
      body = Locaid.defaults.merge body_args
      if body[:application_id]
        body['ClassID'] = body[:application_id]
        body.delete :application_id
      end

      res = savon_request resource, meth, body_args

      res = res.body["#{meth}_response".to_sym][:return]

      error = nil 
      error = res[:error]

      if res[:class_id_list]
        error = res[:class_id_list][:error] if res[:class_id_list][:error]
        error = res[:class_id_list][:msisdn_list][:error] if res[:class_id_list][:msisdn_list] && res[:class_id_list][:msisdn_list][:error]

      elsif res[:msisdn_error]
        error_message = res[:msisdn_error][:error_message]

        if error_message =~ /not subscribed/
          error_message = "the provided phone number has not opted in, cannot get current location"
        end 

        error = {error_code: res[:msisdn_error][:error_code].to_i, error_message: error_message, transaction_id: res[:transaction_id]}
      end 

      raise Locaid::ApiError.new error[:error_code].to_i, error[:error_message], error[:transaction_id] if error

      res 
    end

    def savon_request(resource_name, meth, body_args)
      savon_client(resource_name).request :wsdl, meth.to_s.lower_camelcase do
        soap.body = Locaid.defaults.merge(body_args)
      end
    end

    def savon_client(resource_name)
      wsdl_url = "#{BASE_WSDL_URL}/#{resource_name.to_s.camelcase}?wsdl"
      Savon::Client.new(Locaid.defaults[:cache] == false ? wsdl_url : Locaid.wsdl_cache(wsdl_url))
    end
  end

end