module Fondy
  class Base
    CURRENCY = 'UAH'.freeze
    YES = 'Y'.freeze
    NO = 'N'.freeze
    CARD = 'card'.freeze
    STATUS_TRUE = { status: true }.freeze
    STATUS_FALSE = { status: false }.freeze
    PAYOUT_SUFIX = '_payout'.freeze

    private

    def merchant_id
      ENV['FONDY_MERCHANT_ID'].to_s
    end

    def pass
      instance_of?(ChargeCard) ? ENV['FONDY_MERCHANT_CREDIT_PASS'] : ENV['FONDY_MERCHANT_PASS']
    end

    def amount
      (cost * 100).to_i.to_s
    end

    def signature(params)
      sha = Digest::SHA1.new
      sha.update("#{pass}|#{params.compact.sort.to_h.values.join('|')}")
      { signature: sha.hexdigest }
    end

    def header
      { 'Content-Type' => 'application/json' }
    end

    def response_body(request_body)
      JSON.parse(request_body)['response'].symbolize_keys
    end

    def status(body)
      return STATUS_TRUE if body[:order_status] == Constants::Payments::FONDY_APPROVED && body[:response_status] == Constants::Payments::FONDY_SUCCESS
      return STATUS_TRUE if body[:capture_status] == Constants::Payments::FONDY_CAPTURED && body[:response_status] == Constants::Payments::FONDY_SUCCESS
      return STATUS_TRUE if body[:order_status] == Constants::Payments::FONDY_REVERSED && body[:response_status] == Constants::Payments::FONDY_SUCCESS

      STATUS_FALSE
    end
  end
end
