module Locaid
  class ApiError < StandardError
    def initialize(code, message, transaction_id)
      @code, @message, @transaction_id = code, message, transaction_id
      super "#{message} (code #{code})"
    end
  end
end