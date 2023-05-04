module Fondy
  class Recurring < Base
    URL = URI.parse('https://pay.fondy.eu/api/recurring').freeze

    def initialize(user, cost, rec_token, order_reference, hold = false)
      @user = user
      @cost = cost
      @rec_token = rec_token
      @order_reference = order_reference
      @hold = hold
    end

    def call
      response_body( Net::HTTP.post(URL, request_body, initheader = header).body)
    end

    private

    attr_reader :user, :cost, :rec_token, :order_reference, :hold

    def recuring_params 
      {
        order_id: order_reference,
        order_desc: order_desc,
        currency: CURRENCY,
        rectoken: rec_token,
        preauth: hold ? YES : NO,
        amount: amount.to_i.to_s,
        merchant_id: merchant_id,
        sender_email: user.email
      }
    end
  
    def order_desc
      hold ? 'Hold for trip payment' : 'Payment'
    end

    def request_body
      { request: recuring_params.merge(signature(recuring_params)) }.to_json
    end
  end
end
