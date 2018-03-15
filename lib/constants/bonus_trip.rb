module Constants
  module BonusTrip
    FROZEN  = 0
    NEW     = 1
    USED    = 2
    EXPIRED = 3

    STATUSES = {
      FROZEN  => 'frozen'.freeze,
      NEW     => 'new'.freeze,
      USED    => 'used'.freeze,
      EXPIRED => 'expired'.freeze
    }.freeze

    REFERRAL = 'referral'.freeze
    GIFT     = 'gift'.freeze

    TYPES = [REFERRAL, GIFT].freeze
  end
end
