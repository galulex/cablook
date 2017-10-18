module Constants
  module Trip
    PENDING    = 'pending'.freeze
    ON_THE_WAY = 'on_the_way'.freeze
    DRIVING    = 'driving'.freeze
    CANCELLED  = 'cancelled'.freeze
    FINISHED   = 'finished'.freeze

    STATUSES = {
      PENDING => 0,
      ON_THE_WAY => 1,
      DRIVING => 2,
      CANCELLED => 3,
      FINISHED => 4
    }.freeze
  end
end
