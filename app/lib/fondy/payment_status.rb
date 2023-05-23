module Fondy
  class PaymentStatus < Base
    BASE_URL = 'https://pay.fondy.eu/api/status/order_id'.freeze

    def initialize(order_reference)
      @order_reference = order_reference
    end

    def call
      body.merge(status(body))
    end

    private

    attr_reader :order_reference

    def body
      @body ||= response_body(Net::HTTP.post(URI.parse("#{BASE_URL}/#{order_reference}"), request_body, initheader = header).body)
    end

    def params
      {
        order_id: order_reference,
        merchant_id: merchant_id
      }
    end

    def request_body
      { request: params.merge(signature(params)) }.to_json
    end
  end
end
