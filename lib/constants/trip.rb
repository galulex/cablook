module Constants
  module Trip
    PENDING    = 0
    ON_THE_WAY = 1
    DRIVING    = 3
    CANCELLED  = 4
    FINISHED   = 5

    STATUSES = {
      PENDING     => 'pending'.freeze,
      ON_THE_WAY  => 'on_the_way'.freeze,
      DRIVING     => 'driving'.freeze,
      CANCELLED   => 'cancelled'.freeze,
      FINISHED    => 'finished'.freeze
    }.freeze
  end
end
