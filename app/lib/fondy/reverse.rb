module Fondy
  class Reverse < Base
    URL = URI.parse('https://pay.fondy.eu/api/reverse/order_id').freeze

    def initialize(cost, order_reference)
      @cost = cost
      @order_reference = order_reference
    end

    def call
      { reverse_status: response_body(Net::HTTP.post(URL, request_body, initheader = header).body)[:reverse_status] }
    end

    private

    attr_reader :cost, :rec_token, :order_reference

    def reverse_params
      {
        order_id: order_reference,
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id,
        comment: comment
      }
    end

    def comment
      'Trip canceled by user'
    end

    def request_body
      { request: reverse_params.merge(signature(reverse_params)) }.to_json
    end
  end
end
