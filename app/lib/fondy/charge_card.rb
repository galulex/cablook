module Fondy
  class ChargeCard < Base
    URL = URI.parse('https://pay.fondy.eu/api/p2pcredit/').freeze

    def initialize(order_reference, cost, driver)
      @order_reference = order_reference
      @cost = cost
      @driver = driver
    end

    def call
      return { response_status: 'success', payout: 'Driver payout', status: true } unless Rails.env.production?

      body.merge(status(body))
    end

    private

    attr_reader :order_reference, :cost, :card_number, :driver

    def body
      @body ||= response_body(Net::HTTP.post(URL, request_body, initheader = header).body)
    end

    def params
      {
        order_id: "#{order_reference}_payout",
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id,
        order_desc: order_desc,
        receiver_card_number: driver.card_number
      }
    end

    def request_body
      { request: params.merge(signature(params)) }.to_json
    end

    def order_desc
      "Винагорода #{driver.car.number}"
    end
  end
end
