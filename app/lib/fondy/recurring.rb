module Fondy
  class Recurring < Base
    URL_REC = URI.parse('https://pay.fondy.eu/api/recurring').freeze

    def initialize(user, cost, rec_token, order_reference)
      @user = user
      @cost = cost
      @rec_token = rec_token
      @order_reference = order_reference
    end

    def call
      result(Net::HTTP.post(URL_REC, request_body, initheader = header).body)
    end

    private

    attr_reader :user, :cost, :rec_token, :order_reference

    def recuring_params 
      {
        order_id: order_reference,
        order_desc: order_desc,
        currency: CURRENCY,
        rectoken: rec_token,
        preauth: YES,
        amount: amount,
        merchant_id: merchant_id,
        sender_email: user.email
      }
    end
  
    def order_desc
      'Hold for trip payment'
    end

    def request_body
      { request: recuring_params.merge(signature(recuring_params)) }.to_json
    end

    def result(response_body)
      response = JSON.parse(response_body).dig('response')
      { response_status: response['response_status'] }
    end
  end
end
