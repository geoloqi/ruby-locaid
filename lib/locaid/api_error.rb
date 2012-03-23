module Locaid
  class ApiError < StandardError
    attr_reader :code, :transaction_id
    def initialize(code, message, transaction_id)
      @code, @message, @transaction_id = code, message, transaction_id
      super "#{message} (code #{code})"
    end
  end
end