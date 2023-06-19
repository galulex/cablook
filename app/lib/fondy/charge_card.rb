module Fondy
  class ChargeCard < Base
    URL = URI.parse('https://pay.fondy.eu/api/p2pcredit/').freeze

    def initialize(payment)
      @payment = payment
      @cost = payment.amount
    end

    def call
      return development_response unless Rails.env.production?

      body.merge(status(body))
    end

    private

    attr_reader :payment, :cost

    def body
      @body ||= response_body(Net::HTTP.post(URL, request_body, initheader = header).body)
    end

    def params
      {
        order_id: order_reference,
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id,
        order_desc: order_desc,
        receiver_card_number: payment.driver.card_number,
        reservation_data: reservation_data
      }
    end

    def reservation_data
      Base64.encode64({
        receiver_pan: payment.driver.card_number.to_s
      }.to_json)
    end

    def request_body
      { request: params.merge(signature(params)) }.to_json
    end

    def order_desc
      "Винагорода #{payment.driver.car.number}"
    end

    def development_response
      { order_id: order_reference, response_status: 'success', payout: 'Driver payout', status: true }
    end

    def order_reference
      @order_reference ||= OrderReference.new(payment.trip_id, payment.type).call.concat(PAYOUT_SUFIX)
    end
  end
end
