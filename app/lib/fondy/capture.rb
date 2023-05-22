module Fondy
  class Capture < Base
    URL = URI.parse('https://pay.fondy.eu/api/capture/order_id').freeze

    def initialize(order_id, cost)
      @order_id = order_id
      @cost = cost
    end

    def call
      response_body(Net::HTTP.post(URL, request_body, initheader = header).body)
    end

    private

    attr_reader :order_id, :cost

    def capture_params 
      {
        order_id: order_id,
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id
      }
    end

    def request_body
      { request: capture_params.merge(signature(capture_params)) }.to_json
    end
  end
end
