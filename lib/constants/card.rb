module Constants
  module Card
    # Response Codes from WayForPay
    # https://wiki.wayforpay.com/pages/viewpage.action?pageId=852131

    APPROVED = 'Approved'.freeze
    PAYMENT_SYSTEM = %i[wayforpay fondy].freeze
  end
end
