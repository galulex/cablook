module Fondy
  class ChargeCard < Base
    URL = URI.parse('https://pay.fondy.eu/api/p2pcredit/').freeze

    def initialize(order_reference, cost, card_number)
      @order_reference = order_reference
      @cost = cost
      @card_number = card_number
    end

    def call
      return { response_status: 'success', payout: 'Driver payout'} unless Rails.env.production?
      response_body(Net::HTTP.post(URL, request_body, initheader = header).body)
    end

    private

    attr_reader :order_reference, :cost, :card_number

    def params 
      {
        order_id: order_reference,
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id,
        order_desc: "Test payment",
        receiver_card_number: card_number,
      }
    end

    def request_body
      { request: params.merge(signature(params)) }.to_json
    end
  end
end
