module Constants
  module Trip
    PENDING    = 0
    ON_THE_WAY = 1
    DRIVING    = 2
    FINISHED   = 3
    CANCELED   = 4

    STATUSES = {
      PENDING     => 'pending'.freeze,
      ON_THE_WAY  => 'on_the_way'.freeze,
      DRIVING     => 'driving'.freeze,
      FINISHED    => 'finished'.freeze,
      CANCELED    => 'canceled'.freeze
    }.freeze
  end
end
