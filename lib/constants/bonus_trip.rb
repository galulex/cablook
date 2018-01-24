module Constants
  module BonusTrip
    NEW     = 0
    USED    = 1
    EXPIRED = 2

    STATUSES = {
      NEW     => 'new'.freeze,
      USED    => 'used'.freeze,
      EXPIRED => 'expired'.freeze
    }.freeze
  end
end
