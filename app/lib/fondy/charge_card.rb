module Fondy
  class ChargeCard < Base
    URL = URI.parse('https://pay.fondy.eu/api/p2pcredit/').freeze

    def initialize(driver, cost)
      @driver = driver
      @cost = cost
    end

    def call
      return development_response unless Rails.env.production?

      body.merge(status(body))
    end

    private

    attr_reader :driver, :cost

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
        receiver_card_number: driver.card_number,
        reservation_data: reservation_data,
        receiver_inn: 
      }
    end

    def reservation_data
      Base64.encode64({
        receiver_pan: driver.card_number.to_s
      }.to_json)
    end

    def request_body
      { request: params.merge(signature(params)) }.to_json
    end

    def order_desc
      "Винагорода #{driver.car.number}"
    end

    def development_response
      { order_id: order_reference, response_status: 'success', payout: 'Driver payout', status: true }
    end

    def order_reference
      "payout_##{driver.id}_#{driver.car.number}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
    end

    def receiver_inn
      driver.tin || ''
    end
  end
end
