module Fondy
  class Verify < Base
    URL = URI.parse('https://pay.fondy.eu/api/checkout/url/').freeze
    RESPONSE_URL = 'http://app.lvh.me:3000/api/cards/update'.freeze
    CARD_VERIFY = 'Card verify'.freeze
    CARD_VERIFY_AMOUNT = 100.freeze

    def initialize(current_user)
      @current_user = current_user
    end

    def call
      Net::HTTP.post(URL, request_body, initheader = header).body
    end

    private

    attr_reader :current_user

    def verify_params
      {
        order_id: order_id,
        order_desc: CARD_VERIFY,
        currency: CURRENCY,
        amount: CARD_VERIFY_AMOUNT,
        merchant_id: merchant_id,
        verification: YES,
        required_rectoken: YES,
        payment_systems: CARD,
        default_payment_system: CARD,
        response_url: RESPONSE_URL,
        merchant_data: current_user.id.to_s
      }
    end

    def order_id
      "card_verification_user_#{current_user.id}_#{date_time}"
    end

    def date_time
      DateTime.now.strftime("%Y%m%d_%H%M")
    end

    def request_body
      { request: verify_params.merge(signature(verify_params)) }.to_json
    end
  end
end
