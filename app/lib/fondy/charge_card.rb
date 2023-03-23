module Fondy
  class ChargeCard < Base
    URL = URI.parse('https://pay.fondy.eu/api/p2pcredit/').freeze
    ORDER_ID_SUFIX = '_charge_card'.freeze

    def initialize(order_id, cost, card_number)
      @order_id = order_id
      @cost = cost
      @card_number = card_number
    end

    def call
      Net::HTTP.post(URL, request_body, initheader = header).body
    end

    private

    attr_reader :order_id, :cost, :card_number

    def capture_params 
      {
        order_id: order_id.concat(ORDER_ID_SUFIX),
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id,
        order_desc: "Test payment",
        receiver_card_number: card_number,
      }
    end

    def request_body
      { request: capture_params.merge(signature(capture_params)) }.to_json
    end
  end
end