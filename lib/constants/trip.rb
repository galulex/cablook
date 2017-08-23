module Constants
  module Trip
    PENDING    = 'pending'.freeze
    ON_THE_WAY = 'on_the_way'.freeze
    CANCELLED  = 'cancelled'.freeze
    FINISHED   = 'finished'.freeze

    STATUSES = {
      0 => PENDING,
      1 => ON_THE_WAY,
      2 => CANCELLED,
      3 => FINISHED
    }.freeze
  end
end
