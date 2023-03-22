module Fondy
  class Reverse < Base
    URL_REC = URI.parse('https://pay.fondy.eu/api/reverse/order_id').freeze

    def initialize(user, cost, trip_id)
      @user = user
      @cost = cost
      @trip_id = trip_id
    end

    def call
      result(Net::HTTP.post(URL_REC, request_body, initheader = header).body)
    end

    private

    attr_reader :user, :cost, :rec_token, :trip_id

    def recuring_params 
      {
        order_id: order_id,
        currency: CURRENCY,
        amount: amount,
        merchant_id: merchant_id,
        comment: comment
      }
    end

    def comment
      'Trip canceled by user'
    end

    def request_body
      { request: recuring_params.merge(signature(recuring_params)) }.to_json
    end

    def result(response_body)
      response = JSON.parse(response_body).dig('response')
      { reverse_status: response['reverse_status'] }
    end
  end
end