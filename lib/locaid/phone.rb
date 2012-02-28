module Locaid
  class Phone
    def initialize(msisdn)
      @msisdn = msisdn
    end


    # NONE, means that the requested msisdn has no previous OPTIN record.
    # OPTIN_PENDING, means that the OPTIN command for that classID was given, but no YES/NO response was given.
    # CANCELLED, means that the requested msisdn is unsubscribed from that classId.
    # OPTIN_COMPLETE, means that the requested msisdn is subscribed to that classId.

    def status
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
      status.downcase.to_sym
    end

    def opt_in
      resp = request :registration_services, :subscribePhone, {
        command: 'OPTIN',
        class_id_list: [{
          class_id: Locaid.defaults[:application_id],
          msisdn_list: [@msisdn],
        }]
      }
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
      puts res.inspect
      raise Locaid::ApiError.new(res[:error][:error_code], res[:error][:error_message], res[:error][:transaction_id]) if res[:error]
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