module Locaid
  class Phone
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

    def current_location(accuracy=:agps)
      accuracy = accuracy.to_sym
      raise "accuracy must be agps or celltower, you provided #{accuracy}" if ![:agps, :celltower].include?(accuracy)
      res = request :latitude_longitude_services, :get_locations_x, {
        class_id: Locaid.defaults[:application_id],
        msisdn_list:     [@msisdn],
        location_method: 'A-GPS', #(accuracy == :agps ? 'MOST_ACCURATE' : 'LEAST_EXPENSIVE'),
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
      end

      if error
        raise Locaid::ApiError.new(error[:error_code], error[:error_message], error[:transaction_id])
      end

      res
    end

    def savon_request(resource_name, meth, body_args)
      savon_client(resource_name).request :wsdl, meth.to_s.lower_camelcase do
        soap.body = Locaid.defaults.merge(body_args)
      end
    end

    def savon_client(resource_name)
      Savon::Client.new { wsdl.document = "#{BASE_WSDL_URL}/#{resource_name.to_s.camelcase}?wsdl" }
    end
  end

end