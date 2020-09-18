module Constants
  module BonusTrip
    ICED    = 0
    FRESH   = 1
    USED    = 2
    EXPIRED = 3

    STATUSES = {
      ICED    => 'iced'.freeze,
      FRESH   => 'fresh'.freeze,
      USED    => 'used'.freeze,
      EXPIRED => 'expired'.freeze
    }.freeze

    REFERRAL = 'referral'.freeze
    GIFT     = 'gift'.freeze
    CASHBACK = 'cashback'.freeze

    TYPES = [REFERRAL, GIFT, CASHBACK].freeze
  end
end
